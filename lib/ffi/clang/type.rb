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
		class Type
			attr_reader :type

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

			def variadic?
				Lib.is_function_type_variadic(@type) != 0
			end

			def pod?
				Lib.is_pod_type(@type) != 0
			end

			def num_arg_types
				Lib.get_num_arg_types(@type)
			end

			def pointer?
				[:type_pointer, :type_block_pointer, :type_obj_c_object_pointer, :type_member_pointer].
					include?(self.kind)
			end

			def pointee
				if self.pointer?
					Type.new Lib.get_pointee_type(@type), @translation_unit
				else
					nil
				end
			end

			def canonical
				Type.new Lib.get_canonical_type(@type), @translation_unit
			end

			def class_type
				if self.kind == :type_member_pointer
					Type.new Lib.type_get_class_type(@type), @translation_unit
				else
					nil
				end
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

			def function?
				[:type_function_no_proto, :type_function_proto].include?(self.kind)
			end

			def arg_type(i)
				if self.function?
					Type.new Lib.get_arg_type(@type, i), @translation_unit
				else
					nil
				end
			end

			def result_type
				if self.function?
					Type.new Lib.get_result_type(@type), @translation_unit
				else
					nil
				end
			end

			def element_type
				if self.array? || [:type_vector, :type_complex].include?(self.kind)
					Type.new Lib.get_element_type(@type), @translation_unit
				else
					nil
				end
			end

			def num_elements
				Lib.get_num_elements(@type)
			end

			def array?
				[:type_constant_array, :type_incomplete_array, :type_variable_array, :type_dependent_sized_array].
					include?(self.kind)
			end

			def array_element_type
				if self.array?
					Type.new Lib.get_array_element_type(@type), @translation_unit
				else
					nil
				end
			end

			def array_size
				Lib.get_array_size(@type)
			end

			def alignof
				Lib.type_get_align_of(@type)
			end

			def sizeof
				Lib.type_get_size_of(@type)
			end

			def offsetof(field)
				Lib.type_get_offset_of(@type, field)
			end

			def ref_qualifier
				Lib.type_get_cxx_ref_qualifier(@type)
			end

			def calling_conv
				Lib.get_fuction_type_calling_conv(@type)
			end

			def declaration
				Cursor.new Lib.get_type_declaration(@type), @translation_unit
			end

			def ==(other)
				Lib.equal_types(@type, other.type) != 0
			end
		end
	end
end
