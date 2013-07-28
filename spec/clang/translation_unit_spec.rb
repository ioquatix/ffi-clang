require 'spec_helper'

describe TranslationUnit do
	let(:tu) { Index.new.parse_translation_unit fixture_path("a.c")  }

	it "returns a list of diagnostics" do
		diags = tu.diagnostics
		diags.should be_kind_of(Array)
		diags.should_not be_empty
	end

	it "returns a list of diagnostics from an unsaved file" do
		file = UnsavedFile.new("a.c", File.read(fixture_path("a.c")))
		tu = Index.new.parse_translation_unit("a.c", nil,[file])
		diags = tu.diagnostics
		diags.should be_kind_of(Array)
		diags.should_not be_empty
	end
end
