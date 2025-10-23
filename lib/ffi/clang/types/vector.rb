# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Charlie Savage.
# Copyright, 2025, by Samuel Williams.

module FFI
	module Clang
		module Types
			# Represents a vector type (SIMD vector).
			# Vector types are used for SIMD operations and have a fixed number of elements of the same type.
			class Vector < Type
				# Get the element type of this vector.
				# @returns [Type] The type of elements in this vector.
				def element_type
					Type.create Lib.get_element_type(@type), @translation_unit
				end
				
				# Get the number of elements in this vector.
				# @returns [Integer] The number of elements.
				def size
					Lib.get_num_elements(@type)
				end
			end
		end
	end
end
