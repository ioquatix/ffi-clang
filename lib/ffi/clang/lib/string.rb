# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010, by Jari Bakken.
# Copyright, 2012, by Hal Brodigan.
# Copyright, 2013-2022, by Samuel Williams.

module FFI
	module Clang
		module Lib
			class CXString < FFI::Struct
				layout(
					:data, :pointer,
					:private_flags, :uint
				)
			end

			attach_function :get_string, :clang_getCString, [CXString.by_value], :string
			attach_function :dispose_string, :clang_disposeString, [CXString.by_value], :void

			def self.extract_string(cxstring)
				result = get_string(cxstring)
				dispose_string cxstring

				return result
			end
		end
	end
end
