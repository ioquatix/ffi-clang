# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2019, by Hayden Purdy.
# Copyright, 2022, by Motonori Iwamuro.

require_relative 'index'

module FFI
	module Clang
		module Lib
			typedef :pointer, :CXTranslationUnit

			TranslationUnitFlags = enum [
				:none, 0x0,
				:detailed_preprocessing_record, 0x01,
				:incomplete, 0x02,
				:precompiled_preamble, 0x04,
				:cache_completion_results, 0x08,
				:for_serialization, 0x10,
				:cxx_chained_pch, 0x20,
				:skip_function_bodies, 0x40,
				:include_brief_comments_in_code_completion, 0x80,
				:create_preamble_on_first_parse, 0x100,
				:keep_going, 0x200,
				:single_file_parse, 0x400,
				:limit_skip_function_bodies_to_preamble, 0x800,
				:include_attributed_type, 0x1000,
				:visit_implicit_attributes, 0x2000
			]

			SaveTranslationUnitFlags = enum [
				:save_translation_unit_none, 0x0,
			]

			SaveError = enum [
				:none, 0,
				:unknown, 1,
				:translation_errors, 2,
				:invalid_translation_unit, 3
			]

			ReparseFlags = enum [
				:none, 0x0,
			]

			enum :resource_usage_kind, [
				:ast, 1,
				:identifiers, 2,
				:selectors, 3,
				:global_completion_results, 4,
				:source_manager_content_cache, 5,
				:ast_side_tables, 6,
				:source_manager_membuffer_malloc, 7,
				:source_manager_membuffer_mmap, 8,
				:external_ast_source_membuffer_malloc, 9,
				:external_ast_source_membuffer_mmap, 10,
				:preprocessor, 11,
				:preprocessing_record, 12,
				:sourcemanager_data_structures, 13,
				:preprocessor_header_search, 14,
			]

			class CXTUResourceUsage < FFI::Struct
				layout(
					:data, :pointer,
					:numEntries, :uint,
					:entries, :pointer
				)
			end

			class CXTUResourceUsageEntry < FFI::Struct
				layout(
					:kind, :resource_usage_kind,
					:amount, :ulong,
				)
			end

			# Source code translation units:
			attach_function :parse_translation_unit, :clang_parseTranslationUnit, [:CXIndex, :string, :pointer, :int, :pointer, :uint, :uint], :CXTranslationUnit
			attach_function :create_translation_unit, :clang_createTranslationUnit, [:CXIndex, :string], :CXTranslationUnit
			attach_function :dispose_translation_unit, :clang_disposeTranslationUnit, [:CXTranslationUnit], :void
			attach_function :get_translation_unit_spelling, :clang_getTranslationUnitSpelling, [:CXTranslationUnit], CXString.by_value

			attach_function :default_editing_translation_unit_options, :clang_defaultEditingTranslationUnitOptions, [], :uint
			attach_function :default_save_options, :clang_defaultSaveOptions, [:CXTranslationUnit], :uint
			attach_function :save_translation_unit, :clang_saveTranslationUnit, [:CXTranslationUnit, :string, :uint], :int
			attach_function :default_reparse_options, :clang_defaultReparseOptions, [:CXTranslationUnit], :uint
			attach_function :reparse_translation_unit, :clang_reparseTranslationUnit, [:CXTranslationUnit, :uint, :pointer, :uint], :int

			attach_function :resource_usage, :clang_getCXTUResourceUsage, [:CXTranslationUnit], CXTUResourceUsage.by_value
			attach_function :dispose_resource_usage, :clang_disposeCXTUResourceUsage, [CXTUResourceUsage.by_value], :void
			attach_function :resource_usage_name, :clang_getTUResourceUsageName, [:resource_usage_kind], :string
		end
	end
end
