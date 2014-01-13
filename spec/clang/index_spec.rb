require 'spec_helper'

describe Index do
	let(:index) { Index.new }

	it "can parse a source file" do
		tu = index.parse_translation_unit fixture_path("a.c")
		tu.should be_kind_of(TranslationUnit)
	end

	it "raises error when file is not found" do
		expect { index.parse_translation_unit fixture_path("xxxxxxxxx.c") }.to raise_error
	end
end
