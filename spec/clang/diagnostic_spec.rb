require 'spec_helper'

describe Diagnostic do
  let(:diagnostics) { Index.new.parse_translation_unit(fixture_path("list.c")).diagnostics }
  let(:diagnostic) { diagnostics.first }

  it "returns a string representation of the diagnostic" do
    str = diagnostic.format
    str.should be_kind_of(String)
    str.should =~ /does not match previous/
  end

  it "returns a string representation according to the given opts" do
    diagnostic.format(:source_location => true).should include("list.c:5")
  end

  it "returns the source location" do
    diagnostic.source_location.should be_kind_of(SourceLocation)
  end

  it "returns the text of the diagnostic" do
    diagnostic.spelling.should be_kind_of(String)
  end

  it "returns the severity of the diagnostic" do
    diagnostic.severity.should == :error
  end

  it "returns the ranges of the diagnostic" do
    rs = diagnostics[2].ranges
    rs.should be_kind_of(Array)
    rs.should_not be_empty
    rs.first.should be_kind_of(SourceRange)
  end

end
