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

describe CodeCompletion do
	let(:filename) { fixture_path("completion.cxx") }
	let(:translation_unit) { Index.new.parse_translation_unit(filename) }
	let(:line) { 7 }
	let(:column) { 5 }
	let(:results) { translation_unit.code_complete(filename, line, column) }
	
	describe "self.default_code_completion_options" do
		let(:options) { FFI::Clang::CodeCompletion.default_code_completion_options }
		
		it "returns a default set of code-completion options" do
			expect(options).to be_kind_of(Hash)
			
			options.keys.each do |key|
				expect(FFI::Clang::Lib::CodeCompleteFlags.symbols).to include(key)
			end
		end
	end

	describe CodeCompletion::Results do
		it "can be obtained from a translation unit" do
			expect(results).to be_kind_of(CodeCompletion::Results)
			
			# At least 40 results, depends on standard library implementation:
			expect(results.size).to be >= 40
			
			expect(results.results).to be_kind_of(Array)
			expect(results.results.first).to be_kind_of(CodeCompletion::Result)
		end

		it "calls dispose_code_complete_results on GC" do
			expect(Lib).to receive(:dispose_code_complete_results).at_least(:once)
			expect{results.free}.not_to raise_error
		end

		it "#each" do
			spy = double(stub: nil)
			expect(spy).to receive(:stub).exactly(results.size).times
			results.each { spy.stub }
		end

		it "#num_diagnostics" do
			expect(results.num_diagnostics).to eq(2)
		end

		it "#diagnostic" do
			expect(results.diagnostic(0)).to be_kind_of(Diagnostic)
		end

		it "#diagnostics" do
			expect(results.diagnostics).to be_kind_of(Array)
			expect(results.diagnostics.first).to be_kind_of(Diagnostic)
			expect(results.diagnostics.size).to eq(results.num_diagnostics)
		end

		it "#contexts" do
			expect(results.contexts).to be_kind_of(Hash)
			results.contexts.keys.each { |key|
				expect(FFI::Clang::Lib::CompletionContext.symbols).to include(key)
			}
		end

		it "#container_usr" do
			expect(results.container_usr).to be_kind_of(String)
			expect(results.container_usr).to match(/std.+vector/)
		end

		it "#container_kind" do
			expect(results.container_kind).to be_kind_of(Symbol)
			expect(results.container_kind).to eq(:cursor_class_decl)
		end

		it "#incomplete?" do
			expect(results.incomplete?).to be false
		end

		it "#objc_selector" do
			#TODO
		end

		it "#sort!" do
			results.sort!
			
			possibilities = results.first.string.chunks.select{|x| x[:kind] == :typed_text}.collect{|chunk| chunk[:text]}
			
			# may be sorted with typed_text kind, first result will start with 'a'.. not necessarily
			expect(possibilities).to be == possibilities.sort
		end
	end

	describe CodeCompletion::Result do
		let(:result) { results.results.first }
		it "#string" do
			expect(result.string).to be_kind_of(CodeCompletion::String)
		end

		it "#kind" do
			expect(result.kind).to be_kind_of(Symbol)
		end
	end

	describe CodeCompletion::String do
		subject{ results.sort!; results.find{|x| x.string.chunk_text(0) == 'assign'}.string }

		it "#num_chunks" do
			pp results.size
			# pp results.map{|r| r.string.chunks}
			expect(subject.num_chunks).to be >= 5
		end

		it "#chunk_kind" do
			expect(subject.chunk_kind(0)).to eq(:result_type)
			expect(subject.chunk_kind(1)).to eq(:typed_text)
		end

		it "#chunk_text" do
			expect(subject.chunk_text(0)).to be =~ /void/
			expect(subject.chunk_text(1)).to eq('assign')
		end

		it "#chunk_completion" do
			expect(subject.chunk_completion(0)).to be_kind_of(CodeCompletion::String)
		end

		it "#chunks" do
			expect(subject.chunks).to be_kind_of(Array)
			expect(subject.chunks.first).to be_kind_of(Hash)
			expect(subject.chunks.size).to eq(subject.num_chunks)
		end

		it "#priority" do
			expect(subject.priority).to be_kind_of(Integer)
		end

		it "#availability" do
			expect(subject.availability).to be_kind_of(Symbol)
			expect(subject.availability).to eq(:available)
		end

		it "#num_annotations" do
			expect(subject.num_annotations).to be_kind_of(Integer)
			expect(subject.num_annotations).to eq(0)
		end

		it "#annotation" do
			expect(subject.annotation(100)).to be_nil
			# TODO: need tests for String which has annotation
		end

		it "#annotations" do
			expect(subject.annotations).to be_kind_of(Array)
			# TODO: need tests for String which has annotation
		end

		it "#parent" do
			expect(subject.parent).to be_kind_of(String)
			expect(subject.parent).to be =~ /std.+vector/
		end

		it "#comment" do
			expect(subject.comment).to be_nil
			# TODO: need tests for String which has real comment
		end
	end
end
