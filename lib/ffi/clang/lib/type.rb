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

module FFI
	module Clang
		module Lib
			enum :kind, [
				:type_invalid, 0,
				:type_unexposed, 1,
				:type_void, 2,
				:type_pointer, 101,
				:type_lvalue_ref, 103,
				:type_function_proto, 111
			]

			class CXType < FFI::Struct
				layout(
					:kind, :kind,
					:data, [:pointer, 2]
				)
			end

			attach_function :get_type_spelling, :clang_getTypeSpelling, [CXType.by_value], CXString.by_value
			attach_function :is_function_type_variadic, :clang_isFunctionTypeVariadic, [CXType.by_value], :uint
			attach_function :is_pod_type, :clang_isPODType, [CXType.by_value], :uint
			attach_function :get_num_arg_types, :clang_getNumArgTypes, [CXType.by_value], :int
			attach_function :get_arg_type, :clang_getArgType, [CXType.by_value, :uint], CXType.by_value
			attach_function :get_result_type, :clang_getResultType, [CXType.by_value], CXType.by_value
			attach_function :get_canonical_type, :clang_getCanonicalType, [CXType.by_value], CXType.by_value
			attach_function :is_const_qualified_type, :clang_isConstQualifiedType, [CXType.by_value], :uint
		end
	end
end
