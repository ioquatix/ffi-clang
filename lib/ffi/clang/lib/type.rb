# Copyright, 2013, by Samuel G. D. Williams. <http: //www.codeotaku.com>

# Released under the MIT License.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2013, by Takeshi Watanabe.
# Copyright, 2013-2014, by Masahiro Sano.
# Copyright, 2014, by Niklas Therning.

# Released under the MIT License.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2013-2016, by Samuel Williams.
# Copyright, 2013, by take_cheeze.
# Copyright, 2013-2014, by Masahiro Sano.
# Copyright, 2014, by Niklas Therning.

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

			enum :calling_conv, [
				:calling_conv_default, 0,
				:calling_conv_c, 1,
				:calling_conv_x86_stdcall, 2,
				:calling_conv_x86_fastcall, 3,
				:calling_conv_x86_thiscall, 4,
				:calling_conv_x86_pascal, 5,
				:calling_conv_aapcs, 6,
				:calling_conv_aapcs_vfp, 7,
				:calling_conv_pnacl_call, 8,
				:calling_conv_intel_ocl_bicc, 9,
				:calling_conv_x86_64_win64, 10,
				:calling_conv_x86_64_sysv, 11,
				:calling_conv_invalid, 100,
				:calling_conv_unexposed, 200
			]

			enum :ref_qualifier_kind, [
				:ref_qualifier_none, 0,
				:ref_qualifier_lvalue, 1,
				:ref_qualifier_rvalue, 2,
			]

			enum :layout_error, [
				:layout_error_invalid, -1,
				:layout_error_incomplete, -2,
				:layout_error_dependent, -3,
				:layout_error_not_constant_size, -4,
				:layout_error_invalid_field_name, -5,
			]

			class CXType < FFI::Struct
				layout(
					:kind, :kind,
					:data, [:pointer, 2]
				)
			end

			attach_function :get_type_kind_spelling, :clang_getTypeKindSpelling, [:kind], CXString.by_value
			attach_function :get_type_spelling, :clang_getTypeSpelling, [CXType.by_value], CXString.by_value

			attach_function :is_function_type_variadic, :clang_isFunctionTypeVariadic, [CXType.by_value], :uint
			attach_function :is_pod_type, :clang_isPODType, [CXType.by_value], :uint

			attach_function :get_pointee_type, :clang_getPointeeType, [CXType.by_value], CXType.by_value
			attach_function :get_result_type, :clang_getResultType, [CXType.by_value], CXType.by_value
			attach_function :get_canonical_type, :clang_getCanonicalType, [CXType.by_value], CXType.by_value
			
			attach_function :type_get_class_type, :clang_Type_getClassType, [CXType.by_value], CXType.by_value

			attach_function :is_const_qualified_type, :clang_isConstQualifiedType, [CXType.by_value], :uint
			attach_function :is_volatile_qualified_type, :clang_isVolatileQualifiedType, [CXType.by_value], :uint
			attach_function :is_restrict_qualified_type, :clang_isRestrictQualifiedType, [CXType.by_value], :uint

			attach_function :get_num_arg_types, :clang_getNumArgTypes, [CXType.by_value], :int
			attach_function :get_arg_type, :clang_getArgType, [CXType.by_value, :uint], CXType.by_value
			attach_function :get_num_elements, :clang_getNumElements, [CXType.by_value], :long_long
			attach_function :get_element_type, :clang_getElementType, [CXType.by_value], CXType.by_value
			attach_function :get_array_size, :clang_getArraySize, [CXType.by_value], :long_long
			attach_function :get_array_element_type ,:clang_getArrayElementType, [CXType.by_value], CXType.by_value

			attach_function :type_get_align_of, :clang_Type_getAlignOf, [CXType.by_value], :long_long
			attach_function :type_get_size_of, :clang_Type_getSizeOf, [CXType.by_value], :long_long
			attach_function :type_get_offset_of, :clang_Type_getOffsetOf, [CXType.by_value, :string], :long_long

			attach_function :type_get_cxx_ref_qualifier, :clang_Type_getCXXRefQualifier, [CXType.by_value], :ref_qualifier_kind
			
			attach_function :get_fuction_type_calling_conv, :clang_getFunctionTypeCallingConv, [CXType.by_value], :calling_conv

			attach_function :equal_types, :clang_equalTypes, [CXType.by_value, CXType.by_value], :uint
		end
	end
end
