require 'spec_helper'

module Clang
  describe Diagnostic do
    let(:diag) { Index.new.parse_translation_unit(fixture_path("a.c")).diagnostics.first }

    it "returns a string representation of the diagnostic" do
      str = diag.format
      str.should be_kind_of(String)
      str.should =~ /second parameter of 'main'/
    end

  end
end
