require 'spec_helper'

describe Index do
  let(:index) { Index.new }

  it "can parse a source file" do
    tu = index.parse_translation_unit fixture_path("a.c")
    tu.should be_kind_of(TranslationUnit)
  end
end
