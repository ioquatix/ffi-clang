# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010, by Jari Bakken.
# Copyright, 2012, by Hal Brodigan.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2014, by Masahiro Sano.

describe Diagnostic do
	let(:diagnostics) { Index.new.parse_translation_unit(fixture_path("list.c")).diagnostics }
	let(:diagnostic) { diagnostics.first }

	it "returns a string representation of the diagnostic" do
		str = diagnostic.format
		expect(str).to be_kind_of(String)
		expect(str).to match(/does not match previous/)
	end

	it "returns a string representation according to the given opts" do
		expect(diagnostic.format(:source_location => true)).to include("list.c:5")
	end

	it "returns the text of the diagnostic" do
		expect(diagnostic.spelling).to be_kind_of(String)
	end

	it "returns the severity of the diagnostic" do
		expect(diagnostic.severity).to eq(:error)
	end

	it "returns the ranges of the diagnostic" do
		rs = diagnostics[1].ranges
		expect(rs).to be_kind_of(Array)
		expect(rs).not_to be_empty
		expect(rs.first).to be_kind_of(SourceRange)
	end

	it "calls dispose_diagnostic on GC" do
		diagnostic.autorelease = false
		# expect(Lib).to receive(:dispose_diagnostic).with(diagnostic).once
		expect{diagnostic.free}.not_to raise_error
	end

	context "#self.default_display_opts" do
		it "returns the set of display options" do
			expect(FFI::Clang::Diagnostic.default_display_opts).to be_kind_of(Hash)
			expect(FFI::Clang::Diagnostic.default_display_opts.keys.map(&:class).uniq).to eq([Symbol])
			expect(FFI::Clang::Diagnostic.default_display_opts.values.uniq).to eq([true])
		end
	end

	context "#fixits" do
		it "returns the replacement information by Array of Hash" do
			expect(diagnostic.fixits).to be_kind_of(Array)
			expect(diagnostic.fixits.first).to be_kind_of(Hash)
			expect(diagnostic.fixits.first[:text]).to eq('struct')
			expect(diagnostic.fixits.first[:range]).to be_kind_of(SourceRange)
		end
	end

	context "#children" do
		it "returns child diagnostics by Array" do
			expect(diagnostic.children).to be_kind_of(Array)
			expect(diagnostic.children.first).to be_kind_of(Diagnostic)
			expect(diagnostic.children.first.severity).to eq(:note)
		end
	end

	context "#enable_option" do
		it "returns the name of the command-line option that enabled this diagnostic" do
			expect(diagnostics[3].enable_option).to be_kind_of(String)
			expect(diagnostics[3].enable_option).to eq('-Wempty-body')
		end
	end

	context "#disable_option" do
		it "returns the name of the command-line option that disables this diagnostic" do
			expect(diagnostics[3].disable_option).to be_kind_of(String)
			expect(diagnostics[3].disable_option).to eq('-Wno-empty-body')
		end
	end

	context "#category" do
		it "returns the diagnostic category text" do
			expect(diagnostic.category).to be_kind_of(String)
			expect(diagnostic.category).to eq('Semantic Issue')
		end
	end

	context "#category_id" do
		it "returns the category number" do
			expect(diagnostic.category_id).to be_kind_of(Integer)
			expect(diagnostic.category_id).to eq(2)
		end
	end
end
