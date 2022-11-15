# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014, by Greg Hazel.
# Copyright, 2014-2022, by Samuel Williams.

require_relative 'file'
require_relative 'source_location'

module FFI
	module Clang
		module Lib
			# Source code inclusions:
			callback :visit_inclusion_function, [:CXFile, :pointer, :uint, :pointer], :void
			attach_function :get_inclusions, :clang_getInclusions, [:CXTranslationUnit, :visit_inclusion_function, :pointer], :void      
		end
	end
end
