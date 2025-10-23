module FFI
	module Clang
		# Type system classes for representing C/C++ types.
		# @namespace
		module Types
			# Represents an array type.
			# This includes constant arrays, incomplete arrays, variable arrays, and dependent-sized arrays.
			class Array < Type
				# Get the element type of this array.
				# @returns [Type] The type of elements in this array.
				def element_type
					Type.create Lib.get_array_element_type(@type), @translation_unit
				end

				# Get the size of this array.
				# @returns [Integer] The number of elements in the array, or -1 if the size is not available.
				def size
					Lib.get_array_size(@type)
				end
			end
		end
	end
end
