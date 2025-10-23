# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Charlie Savage.
# Copyright, 2025, by Samuel Williams.

module FFI
	module Clang
		module Types
			# Represents a typedef type.
			# A typedef provides an alias for another type.
			class TypeDef < Type
				# Get the canonical (underlying) type.
				# @returns [Type] The canonical type that this typedef aliases.
				def canonical
					Type.create Lib.get_canonical_type(@type), @translation_unit
				end
				
				# Check if this typedef aliases an anonymous type.
				# @returns [Boolean] True if the canonical type is an anonymous record.
				def anonymous?
					self.canonical.kind == :type_record && self.canonical.anonymous?
				end
			end
		end
	end
end
