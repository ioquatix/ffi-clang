# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2013-2025, by Samuel Williams.
# Copyright, 2013, by Takeshi Watanabe.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2014, by Niklas Therning.
# Copyright, 2024-2025, by Charlie Savage.

module FFI
	module Clang
		module Types
			# Represents a type in the C/C++ type system.
			# This class wraps libclang's type representation and provides methods to query type properties.
			class Type
				# @attribute [r] type
				# 	@returns [FFI::Struct] The underlying CXType structure.
				# @attribute [r] translation_unit
				# 	@returns [TranslationUnit] The translation unit this type belongs to.
				attr_reader :type, :translation_unit
				
				# Create a type instance of the appropriate subclass based on the type kind.
				# @parameter cxtype [FFI::Struct] The low-level CXType structure.
				# @parameter translation_unit [TranslationUnit] The translation unit this type belongs to.
				# @returns [Type] A Type instance of the appropriate subclass.
				def self.create(cxtype, translation_unit)
					case cxtype[:kind]
					when :type_pointer, :type_block_pointer, :type_obj_c_object_pointer, :type_member_pointer
						Pointer.new(cxtype, translation_unit)
					when :type_constant_array, :type_incomplete_array, :type_variable_array, :type_dependent_sized_array
						Array.new(cxtype, translation_unit)
					when :type_vector
						Vector.new(cxtype, translation_unit)
					when :type_function_no_proto, :type_function_proto
						Function.new(cxtype, translation_unit)
					when :type_elaborated
						Elaborated.new(cxtype, translation_unit)
					when :type_typedef
						TypeDef.new(cxtype, translation_unit)
					when :type_record
						Record.new(cxtype, translation_unit)
					else
						Type.new(cxtype, translation_unit)
					end
				end
				
				# Create a new type instance.
				# @parameter type [FFI::Struct] The low-level CXType structure.
				# @parameter translation_unit [TranslationUnit] The translation unit this type belongs to.
				def initialize(type, translation_unit)
					@type = type
					@translation_unit = translation_unit
				end
				
				# Get the kind of this type.
				# @returns [Symbol] The type kind (e.g., :type_int, :type_pointer).
				def kind
					@type[:kind]
				end
				
				# Get the spelling of this type's kind.
				# @returns [String] A human-readable string describing the type kind.
				def kind_spelling
					Lib.extract_string Lib.get_type_kind_spelling @type[:kind]
				end
				
				# Get the spelling of this type.
				# @returns [String] The type as it would appear in source code.
				def spelling
					Lib.extract_string Lib.get_type_spelling(@type)
				end
				
				# Get the canonical type.
				# @returns [Type] The canonical (unqualified, unaliased) form of this type.
				def canonical
					Type.create Lib.get_canonical_type(@type), @translation_unit
				end
				
				# Check if this is a Plain Old Data (POD) type.
				# @returns [Boolean] True if this is a POD type.
				def pod?
					Lib.is_pod_type(@type) != 0
				end
				
				# Check if this type is const-qualified.
				# @returns [Boolean] True if the type has a const qualifier.
				def const_qualified?
					Lib.is_const_qualified_type(@type) != 0
				end
				
				# Check if this type is volatile-qualified.
				# @returns [Boolean] True if the type has a volatile qualifier.
				def volatile_qualified?
					Lib.is_volatile_qualified_type(@type) != 0
				end
				
				# Check if this type is restrict-qualified.
				# @returns [Boolean] True if the type has a restrict qualifier.
				def restrict_qualified?
					Lib.is_restrict_qualified_type(@type) != 0
				end
				
				# Get the alignment of this type in bytes.
				# @returns [Integer] The alignment requirement in bytes.
				def alignof
					Lib.type_get_align_of(@type)
				end
				
				# Get the size of this type in bytes.
				# @returns [Integer] The size in bytes, or -1 if the size cannot be determined.
				def sizeof
					Lib.type_get_size_of(@type)
				end
				
				# Get the ref-qualifier for this type (C++ only).
				# @returns [Symbol] The ref-qualifier (:ref_qualifier_none, :ref_qualifier_lvalue, :ref_qualifier_rvalue).
				def ref_qualifier
					Lib.type_get_cxx_ref_qualifier(@type)
				end
				
				# Get the cursor for the declaration of this type.
				# @returns [Cursor] The cursor representing the type declaration.
				def declaration
					Cursor.new Lib.get_type_declaration(@type), @translation_unit
				end
				
				# Get the non-reference type.
				# For reference types, returns the type that is being referenced.
				# @returns [Type] The non-reference type.
				def non_reference_type
					Type.create Lib.get_non_reference_type(@type), @translation_unit
				end
				
				# Get the type of a template argument at the given index.
				# For template specializations (e.g., std::vector<int>), this returns the type of
				# the template argument at the specified position.
				# @parameter index [Integer] The zero-based index of the template argument.
				# @returns [Type] The type of the template argument at the given index.
				def template_argument_type(index)
					Type.create Lib.get_template_argument_as_type(@type, index), @translation_unit
				end
				
				# Get the number of template arguments for this type.
				# For template specializations (e.g., std::map<int, std::string>), this returns the
				# number of template arguments. Returns -1 if this is not a template specialization.
				# @returns [Integer] The number of template arguments, or -1 if not a template type.
				def num_template_arguments
					Lib.get_num_template_arguments(@type)
				end
				
				# Compare this type with another for equality.
				# @parameter other [Type] The other type to compare.
				# @returns [Boolean] True if the types are equal.
				def ==(other)
					Lib.equal_types(@type, other.type) != 0
				end
				
				# Get a string representation of this type.
				# @returns [String] A string describing this type.
				def to_s
					"#{self.class.name} <#{self.kind}: #{self.spelling}>"
				end
			end
		end
	end
end
