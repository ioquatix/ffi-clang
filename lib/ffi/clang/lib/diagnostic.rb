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

require 'ffi/clang/lib/translation_unit'
require 'ffi/clang/lib/source_location'
require 'ffi/clang/lib/string'

module FFI
	module Clang
		module Lib
			class CXSourceRange < FFI::Struct
				layout(
							 :ptr_data, [:pointer, 2],
							 :begin_int_data, :uint,
							 :end_int_data, :uint
							 )
			end
			
			typedef :pointer, :CXDiagnostic

			# Source code diagnostics:
			attach_function :get_num_diagnostics, :clang_getNumDiagnostics, [:CXTranslationUnit], :uint
			attach_function :get_diagnostic, :clang_getDiagnostic, [:CXTranslationUnit,  :uint], :CXDiagnostic
			attach_function :dispose_diagnostic, :clang_disposeDiagnostic, [:CXDiagnostic], :void
			
			attach_function :get_diagnostic_location, :clang_getDiagnosticLocation, [:CXDiagnostic], CXSourceLocation.by_value
			
			# Diagnostic details and string representations:
			DiagnosticDisplayOptions = enum [:source_location, 0x01, :column, 0x02, :source_ranges, 0x04]
			attach_function :default_diagnostic_display_options, :clang_defaultDiagnosticDisplayOptions, [], :uint
			attach_function :format_diagnostic, :clang_formatDiagnostic, [:CXDiagnostic, :uint], CXString.by_value
			
			attach_function :get_diagnostic_spelling, :clang_getDiagnosticSpelling, [:CXDiagnostic], CXString.by_value
			
			enum :diagnostic_severity, [:ignored, :note, :warning, :error, :fatal]
			attach_function :get_diagnostic_severity, :clang_getDiagnosticSeverity, [:CXDiagnostic], :diagnostic_severity
			
			# Diagnostic source ranges:
			attach_function :get_diagnostic_num_ranges, :clang_getDiagnosticNumRanges, [:CXDiagnostic], :uint
			attach_function :get_diagnostic_range, :clang_getDiagnosticRange, [:CXDiagnostic, :uint], CXSourceRange.by_value
			
			# Range to source code location conversion:
			attach_function :get_range_start, :clang_getRangeStart, [CXSourceRange.by_value], CXSourceLocation.by_value
			attach_function :get_range_end, :clang_getRangeEnd, [CXSourceRange.by_value], CXSourceLocation.by_value
			
			attach_function :equal_locations, :clang_equalLocations, [CXSourceLocation.by_value, CXSourceLocation.by_value], :uint
		end
	end
end
