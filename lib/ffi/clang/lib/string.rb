# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2013-2025, by Samuel Williams.

module FFI
	module Clang
		module Lib
			# FFI struct representing a string returned by libclang.
			# @private
			class CXString < FFI::Struct
				layout(
					:data, :pointer,
					:private_flags, :uint
				)
			end
			
			attach_function :get_string, :clang_getCString, [CXString.by_value], :string
			attach_function :dispose_string, :clang_disposeString, [CXString.by_value], :void
			
			# Extract a Ruby string from a CXString and dispose of the CXString.
			# @parameter cxstring [CXString] The CXString to extract from.
			# @returns [String] The extracted string.
			def self.extract_string(cxstring)
				result = get_string(cxstring)
				dispose_string cxstring
				
				return result
			end
		end
	end
end
