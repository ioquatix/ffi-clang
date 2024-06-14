module FFI
	module Clang
		module Types
			class Function < Type
				def variadic?
					Lib.is_function_type_variadic(@type) != 0
				end

				def args_size
					Lib.get_num_arg_types(@type)
				end

				def arg_type(i)
					Type.create Lib.get_arg_type(@type, i), @translation_unit
				end

				def result_type
					Type.create Lib.get_result_type(@type), @translation_unit
				end

				def calling_conv
					Lib.get_fuction_type_calling_conv(@type)
				end
			end
		end
	end
end