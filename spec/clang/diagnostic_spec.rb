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

	it "returns the text of the diagnostic" do
		diagnostic.spelling.should be_kind_of(String)
	end

	it "returns the severity of the diagnostic" do
		diagnostic.severity.should == :error
	end

	it "returns the ranges of the diagnostic" do
		rs = diagnostics[1].ranges
		rs.should be_kind_of(Array)
		rs.should_not be_empty
		rs.first.should be_kind_of(SourceRange)
	end

	it "calls dispose_diagnostic on GC" do
		expect(Lib).to receive(:dispose_diagnostic).with(diagnostic).at_least(:once)
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
