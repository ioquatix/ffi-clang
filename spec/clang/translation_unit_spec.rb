require 'spec_helper'

describe TranslationUnit do
	let(:tu) { Index.new.parse_translation_unit fixture_path("a.c")  }

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
		expect(Lib).to receive(:dispose_translation_unit).with(tu)
		expect{tu.free}.not_to raise_error
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
end
