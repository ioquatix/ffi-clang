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

require_relative 'translation_unit'
require_relative 'source_location'
require_relative 'string'
require_relative 'source_range'

module FFI
	module Clang
		module Lib
			typedef :pointer, :CXDiagnostic
			typedef :pointer, :CXDiagnosticSet

			DiagnosticDisplayOptions = enum [
				:source_location, 0x01,
				:column, 0x02,
				:source_ranges, 0x04,
				:option, 0x08,
				:category_id, 0x10,
				:category_name , 0x20,
			]

			enum :diagnostic_severity, [:ignored, :note, :warning, :error, :fatal]

			# Source code diagnostics:
			attach_function :get_num_diagnostics, :clang_getNumDiagnostics, [:CXTranslationUnit], :uint
			attach_function :get_diagnostic, :clang_getDiagnostic, [:CXTranslationUnit, :uint], :CXDiagnostic
			attach_function :dispose_diagnostic, :clang_disposeDiagnostic, [:CXDiagnostic], :void

			# DiagnosticSet (not used yet)
			# attach_function :get_diagnostic_set_from_translation_unit, :clang_getDiagnosticSetFromTU, [:CXTranslationUnit], :CXDiagnosticSet
			# attach_function :dispose_diagnostic_set, :clang_disposeDiagnosticSet, [:CXDiagnosticSet], :void
			# attach_function :load_diagnostics, :clang_loadDiagnostics, [:string, :pointer, :pointer], :CXDiagnosticSet

			# Diagnostic details and string representations:
			attach_function :get_diagnostic_spelling, :clang_getDiagnosticSpelling, [:CXDiagnostic], CXString.by_value
			attach_function :default_diagnostic_display_options, :clang_defaultDiagnosticDisplayOptions, [], :uint
			attach_function :format_diagnostic, :clang_formatDiagnostic, [:CXDiagnostic, :uint], CXString.by_value
			attach_function :get_diagnostic_severity, :clang_getDiagnosticSeverity, [:CXDiagnostic], :diagnostic_severity
			attach_function :get_diagnostic_option, :clang_getDiagnosticOption, [:CXDiagnostic, :pointer], CXString.by_value

			# Diagnostic source location and source ranges:
			attach_function :get_diagnostic_location, :clang_getDiagnosticLocation, [:CXDiagnostic], CXSourceLocation.by_value
			attach_function :get_diagnostic_num_ranges, :clang_getDiagnosticNumRanges, [:CXDiagnostic], :uint
			attach_function :get_diagnostic_range, :clang_getDiagnosticRange, [:CXDiagnostic, :uint], CXSourceRange.by_value

			# Child Diagnostics:
			attach_function :get_child_diagnostics, :clang_getChildDiagnostics, [:CXDiagnostic], :CXDiagnosticSet
			attach_function :get_num_diagnostics_in_set, :clang_getNumDiagnosticsInSet, [:CXDiagnosticSet], :uint
			attach_function :get_diagnostic_in_set, :clang_getDiagnosticInSet, [:CXDiagnosticSet, :uint], :CXDiagnostic

			# Category:
			attach_function :get_diagnostic_category, :clang_getDiagnosticCategory, [:CXDiagnostic], :uint
			attach_function :get_diagnostic_category_text, :clang_getDiagnosticCategoryText, [:CXDiagnostic], CXString.by_value

			# Fixit:
			attach_function :get_diagnostic_num_fix_its, :clang_getDiagnosticNumFixIts, [:CXDiagnostic], :uint
			attach_function :get_diagnostic_fix_it, :clang_getDiagnosticFixIt, [:CXDiagnostic, :uint, :pointer], CXString.by_value
		end
	end
end
