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
				:type_bool, 3,
				:type_char_u, 4,
				:type_uchar, 5,
				:type_char16, 6,
				:type_char32, 7,
				:type_ushort, 8,
				:type_uint, 9,
				:type_ulong, 10,
				:type_ulonglong, 11,
				:type_uint128, 12,
				:type_char_s, 13,
				:type_schar, 14,
				:type_wchar, 15,
				:type_short, 16,
				:type_int, 17,
				:type_long, 18,
				:type_longlong, 19,
				:type_int128, 20,
				:type_float, 21,
				:type_double, 22,
				:type_longdouble, 23,
				:type_nullptr, 24,
				:type_overload, 25,
				:type_dependent, 26,
				:type_obj_c_id, 27,
				:type_obj_c_class, 28,
				:type_obj_c_sel, 29,
				:type_complex, 100,
				:type_pointer, 101,
				:type_block_pointer, 102,
				:type_lvalue_ref, 103,
				:type_rvalue_ref, 104,
				:type_record, 105,
				:type_enum, 106,
				:type_typedef, 107,
				:type_obj_c_interface, 108,
				:type_obj_c_object_pointer, 109,
				:type_function_no_proto, 110,
				:type_function_proto, 111,
				:type_constant_array, 112,
				:type_vector, 113,
				:type_incomplete_array, 114,
				:type_variable_array, 115,
				:type_dependent_sized_array, 116,
				:type_member_pointer, 117,
			]

			class CXType < FFI::Struct
				layout(
					:kind, :kind,
					:data, [:pointer, 2]
				)
			end

			attach_function :get_pointee_type, :clang_getPointeeType, [CXType.by_value], CXType.by_value
			attach_function :get_type_kind_spelling, :clang_getTypeKindSpelling, [:kind], CXString.by_value
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
