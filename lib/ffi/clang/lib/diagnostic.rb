# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2013, by Garry Marshall.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2020, by Luikore.

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
