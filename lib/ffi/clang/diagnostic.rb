# -*- coding: utf-8 -*-
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

require 'ffi/clang/lib/diagnostic'
require 'ffi/clang/source_range'

module FFI
	module Clang
		class Diagnostic < AutoPointer
			def initialize(translation_unit, pointer)
				super pointer

				@translation_unit = translation_unit
			end

			def self.release(pointer)
				Lib.dispose_diagnostic(pointer)
			end

			def format(opts = {})
				cxstring = Lib.format_diagnostic(self, display_opts(opts))
				Lib.extract_string cxstring
			end

			def severity
				Lib.get_diagnostic_severity self
			end

			def spelling
				Lib.get_string Lib.get_diagnostic_spelling(self)
			end

			def location
				sl = Lib.get_diagnostic_location(self)
				ExpansionLocation.new sl
			end

			def fixits
				raise NotImplementedError
				# unsigned clang_getDiagnosticNumFixIts(CXDiagnostic Diag);
				# – CXString clang_getDiagnosticFixIt(CXDiagnostic Diag,
				#                                     unsigned FixIt,
				#                                     CXSourceRange *ReplacementRange);
			end

			def ranges
				n = Lib.get_diagnostic_num_ranges(self)
				
				n.times.map {|i| SourceRange.new Lib.get_diagnostic_range(self, i)}
			end

			private

			def range_count
				
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
