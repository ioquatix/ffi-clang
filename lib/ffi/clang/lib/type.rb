module FFI
	module Clang
		module Lib
			enum :kind, [
									 :type_invalid, 0,
									 :type_unexposed, 1,
									 :type_void, 2,
									 :type_pointer, 101,
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

		end
	end
end
