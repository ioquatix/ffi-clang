# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Charlie Savage.
# Copyright, 2025, by Samuel Williams.

module FFI
	module Clang
		module Types
			# Represents a function type.
			# This includes functions with and without prototypes.
			class Function < Type
				include Enumerable
				
				# Check if this function is variadic.
				# @returns [Boolean] True if the function accepts a variable number of arguments.
				def variadic?
					Lib.is_function_type_variadic(@type) != 0
				end
				
				# Get the number of arguments this function takes.
				# @returns [Integer] The number of arguments.
				def args_size
					Lib.get_num_arg_types(@type)
				end
				
				# Get the type of a specific argument.
				# @parameter i [Integer] The zero-based argument index.
				# @returns [Type] The type of the argument at the specified index.
				def arg_type(i)
					Type.create Lib.get_arg_type(@type, i), @translation_unit
				end
				
				# Iterate over all argument types or get an enumerator.
				# @yields {|type| ...} Yields each argument type if a block is given.
				# 	@parameter type [Type] An argument type.
				# @returns [Enumerator, self] An enumerator if no block is given, self otherwise.
				def arg_types
					return to_enum(:arg_types) unless block_given?
					
					self.args_size.times do |i|
						yield self.arg_type(i)
					end
					
					self
				end
				
				# Get the return type of this function.
				# @returns [Type] The function's return type.
				def result_type
					Type.create Lib.get_result_type(@type), @translation_unit
				end
				
				# Get the calling convention of this function.
				# @returns [Symbol] The calling convention (e.g., :calling_conv_c, :calling_conv_x86_stdcall).
				def calling_conv
					Lib.get_fuction_type_calling_conv(@type)
				end
				
				# Get the exception specification type for this function.
				# @returns [Symbol] The exception specification type (e.g., :exception_spec_none, :exception_spec_basic_noexcept).
				def exception_specification
					Lib.get_exception_specification_type(@type)
				end
			end
		end
	end
end
