require 'spec_helper'

module Clang
  describe Diagnostic do
    let(:diag) { Index.new.parse_translation_unit(fixture_path("list.c")).diagnostics.first }

    it "returns a string representation of the diagnostic" do
      str = diag.format
      str.should be_kind_of(String)
      str.should =~ /does not match previous/
    end

    it "returns a string representation according to the given opts" do
      diag.format(:source_location => true).should include("list.c:5")
    end

    # it "returns the source location" do
    #   diag.source_location.should be_kind_of(SourceLocation)
    # end

    it "returns the text of the diagnostic" do
      diag.spelling.should be_kind_of(String)
    end

    it "returns the severity of the diagnostic" do
      diag.severity.should == :error
    end

    it "returns the ranges of the diagnostic" do
      rs = diag.ranges
      rs.should be_kind_of(Array)
      rs.should_not be_empty
      rs.first.should be_kind_of(SourceRange)
    end

  end
end
