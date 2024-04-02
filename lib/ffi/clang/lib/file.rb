# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010, by Jari Bakken.
# Copyright, 2012, by Hal Brodigan.
# Copyright, 2013-2024, by Samuel Williams.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2014, by Masahiro Sano.

require_relative 'string'
require_relative 'translation_unit'

module FFI
	module Clang
		module Lib
			class CXUnsavedFile < FFI::Struct
				layout(
					:filename, :pointer,
					:contents, :pointer,
					:length, :ulong
				)
			end

			class CXFileUniqueID < FFI::Struct
				layout(
					:device, :ulong_long,
					:inode, :ulong_long,
					:modification, :ulong_long
				)
			end

			typedef :pointer, :CXFile

			attach_function :get_file, :clang_getFile, [:CXTranslationUnit, :string], :CXFile
			attach_function :get_file_name, :clang_getFileName, [:CXFile], CXString.by_value
			attach_function :get_file_time, :clang_getFileTime, [:CXFile], :time_t
			attach_function :is_file_multiple_include_guarded, :clang_isFileMultipleIncludeGuarded, [:CXTranslationUnit, :CXFile], :int
			
			attach_function :get_file_unique_id, :clang_getFileUniqueID, [:CXFile, :pointer], :int
		end
	end
end
