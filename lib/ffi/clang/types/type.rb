# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2013-2024, by Samuel Williams.
# Copyright, 2013, by Takeshi Watanabe.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2014, by Niklas Therning.
# Copyright, 2024, by Charlie Savage.

module FFI
	module Clang
		module Types
			class Type
				attr_reader :type, :translation_unit

				# Just hard code the types - they are not likely to change
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

				def initialize(type, translation_unit)
					@type = type
					@translation_unit = translation_unit
				end

				def kind
					@type[:kind]
				end

				def kind_spelling
					Lib.extract_string Lib.get_type_kind_spelling @type[:kind]
				end

				def spelling
					Lib.extract_string Lib.get_type_spelling(@type)
				end

				def canonical
					Type.create Lib.get_canonical_type(@type), @translation_unit
				end

				def pod?
					Lib.is_pod_type(@type) != 0
				end

				def const_qualified?
					Lib.is_const_qualified_type(@type) != 0
				end

				def volatile_qualified?
					Lib.is_volatile_qualified_type(@type) != 0
				end

				def restrict_qualified?
					Lib.is_restrict_qualified_type(@type) != 0
				end

				def alignof
					Lib.type_get_align_of(@type)
				end

				def sizeof
					Lib.type_get_size_of(@type)
				end

				def ref_qualifier
					Lib.type_get_cxx_ref_qualifier(@type)
				end

				def declaration
					Cursor.new Lib.get_type_declaration(@type), @translation_unit
				end

				def non_reference_type
					Type.create Lib.get_non_reference_type(@type),@translation_unit
				end

				def ==(other)
					Lib.equal_types(@type, other.type) != 0
				end

				def to_s
					"#{self.class.name} <#{self.kind}: #{self.spelling}>"
				end
			end
		end
	end
end
