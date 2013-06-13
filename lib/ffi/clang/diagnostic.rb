# Copyright, 2010-2012 by Jari Bakken.
# Copyright, 2013, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

module FFI
	module Clang
		class Diagnostic
			def initialize(tu, ptr)
				@tu = tu
				@ptr = AutoPointer.new(ptr, Lib.method(:dispose_diagnostic_debug))
			end

			def format(opts = {})
				cxstring = Lib.format_diagnostic(@ptr, display_opts(opts))
				Lib.extract_string cxstring
			end

			def severity
				Lib.get_diagnostic_severity @ptr
			end

			def source_location
				sl = Lib.get_diagnostic_location @ptr
				SourceLocation.new(self, sl)
			end

			def spelling
				Lib.get_c_string Lib.get_diagnostic_spelling(@ptr)
			end

			def fixits
				raise NotImplementedError
				# unsigned clang_getDiagnosticNumFixIts(CXDiagnostic Diag);
				# – CXString clang_getDiagnosticFixIt(CXDiagnostic Diag,
				#                                     unsigned FixIt,
				#                                     CXSourceRange *ReplacementRange);

			end

			def ranges
				0.upto(range_count - 1).map { |idx|
					SourceRange.new Lib.get_diagnostic_range(@ptr, idx)
				}
			end

			private

			def range_count
				Lib.get_diagnostic_num_ranges @ptr
			end

			def display_opts(opts)
				if opts.empty?
					Lib.default_diagnostic_display_options
				else
					Lib.bitmask_from Lib::DiagnosticDisplayOptions, opts
				end
			end

		end
	end
end
