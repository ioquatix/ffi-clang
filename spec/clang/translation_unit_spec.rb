# Copyright, 2014, by Masahiro Sano.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'spec_helper'

describe TranslationUnit do
	before :all do
		FileUtils.mkdir_p TMP_DIR
	end

	after :all do
		FileUtils.rm_rf TMP_DIR
	end

	let(:tu) { Index.new.parse_translation_unit fixture_path("a.c") }

	it "returns a list of diagnostics" do
		diags = tu.diagnostics
		expect(diags).to be_kind_of(Array)
		expect(diags).to_not be_empty
	end

	it "returns a list of diagnostics from an unsaved file" do
		file = UnsavedFile.new("a.c", File.read(fixture_path("a.c")))
		tu = Index.new.parse_translation_unit("a.c", nil,[file])
		diags = tu.diagnostics
		expect(diags).to be_kind_of(Array)
		expect(diags).to_not be_empty
	end

	it "calls dispose_translation_unit on GC" do
		tu.autorelease = false
		expect(Lib).to receive(:dispose_translation_unit).with(tu).once
		expect{tu.free}.not_to raise_error
	end

	describe "#spelling" do
		let (:spelling) { tu.spelling }

		it "returns own filename" do
			expect(spelling).to be_kind_of(String)
			expect(spelling).to eq(fixture_path("a.c"))
		end
	end

	describe "#file" do
		let (:file) { tu.file(fixture_path("a.c")) }

		it "returns File instance" do
			expect(file).to be_kind_of(FFI::Clang::File)
		end
	end

	describe "#location" do
		let(:file) { tu.file(fixture_path("a.c")) }
		let(:column) { 12 }
		let(:location) { tu.location(file, 1, column) }

		it "returns source location at a specific point" do
			expect(location).to be_kind_of(SourceLocation)
			expect(location.file).to eq(fixture_path("a.c"))
			expect(location.line).to eq(1)
			expect(location.column).to eq(column)
		end
	end

	describe "#location_offset" do
		let(:file) { tu.file(fixture_path("a.c")) }
		let(:offset) { 10 }
		let(:location) { tu.location_offset(file, offset) }

		it "returns source location at a specific offset point" do
			expect(location).to be_kind_of(SourceLocation)
			expect(location.file).to eq(fixture_path("a.c"))
			expect(location.column).to eq(offset+1)
		end
	end

	describe "#cursor" do
		let(:cursor) { tu.cursor }
		let(:location) { tu.location(tu.file(fixture_path("a.c")), 1, 10) }
		let(:cursor_with_loc) { tu.cursor(location) }

		it "returns translation unit cursor if no arguments are specified" do
			expect(cursor).to be_kind_of(Cursor)
			expect(cursor.kind).to eq(:cursor_translation_unit)
		end

		it "returns a correspond cursor if a source location is passed" do
			expect(cursor_with_loc).to be_kind_of(Cursor)
			expect(cursor_with_loc.kind).to eq(:cursor_parm_decl)
		end
	end

	describe "#self.default_editing_translation_unit_options" do
		let (:opts) { FFI::Clang::TranslationUnit.default_editing_translation_unit_options }
		it "returns hash with symbols of TranslationUnitFlags" do
			expect(opts).to be_kind_of(Hash)
			opts.keys.each { |key|
				expect(FFI::Clang::Lib::TranslationUnitFlags.symbols).to include(key)
			}
		end
	end

	describe "#default_save_options" do
		let (:opts) { tu.default_save_options }
		it "returns hash with symbols of SaveTranslationUnitFlags" do
			expect(opts).to be_kind_of(Hash)
			opts.keys.each { |key|
				expect(FFI::Clang::Lib::SaveTranslationUnitFlags.symbols).to include(key)
			}
		end
	end

	describe "#save" do
		let (:filepath) { "#{TMP_DIR}/save_translation_unit" }
		let (:may_not_exist_filepath) { "#{TMP_DIR}/not_writable_directory/save_translation_unit" }
		it "saves translation unit as a file" do
			expect{tu.save(filepath)}.not_to raise_error
			expect(FileTest.exist?(filepath)).to be_true
		end

		it "raises exception if save path is not writable" do
			FileUtils.mkdir_p File.dirname(may_not_exist_filepath)
			File.chmod(0444, File.dirname(may_not_exist_filepath))
			expect{tu.save(may_not_exist_filepath)}.to raise_error
			expect(FileTest.exist?(may_not_exist_filepath)).to be_false
		end
	end

	describe "#default_reparse_options" do
		let (:opts) { tu.default_reparse_options }
		it "returns hash with symbols of ReparseFlags" do
			expect(opts).to be_kind_of(Hash)
			opts.keys.each { |key|
				expect(FFI::Clang::Lib::ReparseFlags.symbols).to include(key)
			}
		end
	end

	describe "#reparse" do
		let (:path) { "#{TMP_DIR}/reparse_tmp.c" }
		before :each do
			FileUtils.touch path
			@reparse_tu = Index.new.parse_translation_unit(path)
		end
		after :each do
			FileUtils.rm path, :force => true
		end

		it "recretes translation unit" do
			File::open(path, "w+") { |io|
			   io.write("int a;")
			}
			expect(find_first(@reparse_tu.cursor, :cursor_variable)).to be_false
			expect{@reparse_tu.reparse}.not_to raise_error
			expect(find_first(@reparse_tu.cursor, :cursor_variable).spelling).to eq("a")
		end

		it "raises exception if the file is not found when reparsing" do
			FileUtils.rm path, :force => true
			expect{@reparse_tu.reparse}.to raise_error
		end
	end

	describe "#resource_usage" do
		let (:ru) { tu.resource_usage }
		it "returns ResourceUsage instance that represents memory usage of TU" do
			expect(ru).to be_kind_of(TranslationUnit::ResourceUsage)
		end
	end

	describe TranslationUnit::ResourceUsage do
		let (:ru) { tu.resource_usage }
		describe "#entries" do
			let (:entries) { tu.resource_usage.entries }
			it "returns array of CXTUResourceUsageEntry" do
				expect(entries).to be_kind_of(Array)
				expect(entries.first).to be_kind_of(Lib::CXTUResourceUsageEntry)
				expect(entries.first[:kind]).to be_kind_of(Symbol)
				expect(entries.first[:amount]).to be_kind_of(Integer)
			end
		end

		describe "#self.name" do
			let(:name) { FFI::Clang::TranslationUnit::ResourceUsage.name(:ast) }
			it "returns the name of the memory category" do
				expect(name).to be_kind_of(String)
			end
		end

		describe "#self.release" do
			it "releases data by calling 'clang_disposeCXTUResourceUsage'" do
				ru.autorelease = false
				expect{ ru.free }.not_to raise_error
			end
		end
	end
end
