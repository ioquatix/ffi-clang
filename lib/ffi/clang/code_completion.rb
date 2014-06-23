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

require 'ffi/clang/lib/code_completion'

module FFI
	module Clang
		class CodeCompletion
			def self.default_code_completion_options
				Lib.opts_from Lib::CodeCompleteFlags, Lib.default_code_completion_options
			end

			class Results < FFI::AutoPointer
				include Enumerable

				attr_reader :size
				attr_reader :results

				def initialize(code_complete_results, translation_unit)
					super code_complete_results.pointer
					@translation_unit = translation_unit
					@code_complete_results = code_complete_results
					initialize_results
				end

				def self.release(pointer)
					Lib.dispose_code_complete_results(pointer)
				end

				def each(&block)
					@results.each do |token|
						block.call(token)
					end
				end

				def num_diagnostics
					Lib.get_code_complete_get_num_diagnostics(@code_complete_results)
				end

				def diagnostic(i)
					Diagnostic.new(@translation_unit, Lib.get_code_complete_get_diagnostic(@code_complete_results, i))
				end

				def diagnostics
					num_diagnostics.times.map { |i|
						Diagnostic.new(@translation_unit, Lib.get_code_complete_get_diagnostic(@code_complete_results, i))
					}
				end

				def contexts
					Lib.opts_from Lib::CompletionContext, Lib.get_code_complete_get_contexts(@code_complete_results)
				end

				def container_usr
					Lib.extract_string Lib.get_code_complete_get_container_usr(@code_complete_results)
				end

				def container_kind
					is_incomplete = MemoryPointer.new :uint
					Lib.get_code_complete_get_container_kind(@code_complete_results, is_incomplete)
				end

				def incomplete?
					is_incomplete = MemoryPointer.new :uint
					Lib.get_code_complete_get_container_kind(@code_complete_results, is_incomplete)
					is_incomplete.read_uint != 0
				end

				def objc_selector
					Lib.extract_string Lib.get_code_complete_get_objc_selector(@code_complete_results)
				end

				def sort!
					Lib.sort_code_completion_results(@code_complete_results[:results], @code_complete_results[:num])
					initialize_results
				end

				def inspect
					@results.inspect
				end

				private

				def initialize_results
					@size = @code_complete_results[:num]
					cur_ptr = @code_complete_results[:results]
					@results = []
					@size.times {
						@results << Result.new(Lib::CXCompletionResult.new(cur_ptr))
						cur_ptr += Lib::CXCompletionResult.size
					}
				end
			end

			class Result
				def initialize(result)
					@result = result
				end

				def kind
					@result[:kind]
				end

				def string
					CodeCompletion::String.new @result[:string]
				end

				def inspect
					"<#{kind.inspect} = #{string.inspect}>"
				end
			end

			class String
				def initialize(ptr)
					@pointer = ptr
				end

				def chunk_kind(i)
					Lib.get_completion_chunk_kind(@pointer, i)
				end

				def chunk_text(i)
					Lib.extract_string Lib.get_completion_text(@pointer, i)
				end

				def chunk_completion(i)
					CodeCompletion::String.new Lib.get_completion_chunk_completion_string(@pointer, i)
				end

				def num_chunks
					Lib.get_num_completion_chunks(@pointer)
				end

				def chunks
					num_chunks.times.map { |i|
						{ kind: chunk_kind(i), text: chunk_text(i), completion: chunk_completion(i) }
					}
				end

				def priority
					Lib.get_completion_priority(@pointer)
				end

				def availability
					Lib.get_completion_availability(@pointer)
				end

				def num_annotations
					Lib.get_completion_num_annotations(@pointer)
				end

				def annotation(i)
					Lib.extract_string Lib.get_completion_annotation(@pointer, i)
				end

				def annotations
					num_annotations.times.map { |i|
						Lib.extract_string Lib.get_completion_annotation(@pointer, i)
					}
				end

				def parent
					Lib.extract_string Lib.get_completion_parent(@pointer, nil)
				end

				def comment
					Lib.extract_string Lib.get_completion_brief_comment(@pointer)
				end

				def inspect
					chunks.inspect
				end
			end
		end
	end
end
