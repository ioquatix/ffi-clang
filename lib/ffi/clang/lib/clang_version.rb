# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2014-2022, by Samuel Williams.

require_relative 'string'

module FFI
	module Clang
		module Lib
			attach_function :get_clang_version, :clang_getClangVersion, [], CXString.by_value
		end
	end
end
