module FFI
	module Clang
		module Types
			# Represents an elaborated type (e.g., struct, union, enum with an elaborated type specifier).
			# Elaborated types may include type qualifiers and nested name specifiers.
			class Elaborated < Type
				# Get the named type that this elaborated type refers to.
				# @returns [Type] The underlying named type.
				def named_type
					Type.create Lib.get_named_type(@type), @translation_unit
				end

				# Check if this is an anonymous elaborated type.
				# Example anonymous union where `u` is an elaborated type:
				#
				#	 typedef struct {
				#		 union {
				#			 int idata;
				#		 } u;
				#	 } SomeStruct;
				#
				# @returns [Boolean] True if this elaborated type is anonymous.
				def anonymous?
					self.declaration.anonymous?
				end

				# Check if this elaborated type is a pointer in its canonical form.
				# @returns [Boolean] True if the canonical type is a pointer.
				def pointer?
					self.canonical.is_a?(Pointer)
				end
			end
		end
	end
end