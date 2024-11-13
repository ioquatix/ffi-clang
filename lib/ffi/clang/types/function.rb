module FFI
	module Clang
		module Types
			class Function < Type
				include Enumerable

				def variadic?
					Lib.is_function_type_variadic(@type) != 0
				end

				def args_size
					Lib.get_num_arg_types(@type)
				end

				def arg_type(i)
					Type.create Lib.get_arg_type(@type, i), @translation_unit
				end

				def arg_types
					return to_enum(:arg_types) unless block_given?

					self.args_size.times do |i|
						yield self.arg_type(i)
					end

					self
				end

				def result_type
					Type.create Lib.get_result_type(@type), @translation_unit
				end

				def calling_conv
					Lib.get_fuction_type_calling_conv(@type)
				end

				def exception_specification
					Lib.get_exception_specification_type(@type)
				end
			end
		end
	end
end