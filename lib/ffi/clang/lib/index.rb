# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010, by Jari Bakken.
# Copyright, 2012, by Hal Brodigan.
# Copyright, 2013-2022, by Samuel Williams.

module FFI
	module Clang
		module Lib
			typedef :pointer, :CXIndex

			# Source code index:
			attach_function :create_index, :clang_createIndex, [:int, :int], :CXIndex
			attach_function :dispose_index, :clang_disposeIndex, [:CXIndex], :void
		end
	end
end
