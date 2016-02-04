# Copyright, 2013, by Samuel G. D. Williams. <http://www.codeotaku.com>
# Copyright, 2014, by Masahiro Sano.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'ffi/clang/cursor'

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

			def pointee
				Type.new Lib.get_pointee_type(@type), @translation_unit
			end

			def canonical
				Type.new Lib.get_canonical_type(@type), @translation_unit
			end

			def class_type
				Type.new Lib.type_get_class_type(@type), @translation_unit
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

			def arg_type(i)
				Type.new Lib.get_arg_type(@type, i), @translation_unit
			end

			def result_type
				Type.new Lib.get_result_type(@type), @translation_unit
			end

			def element_type
				Type.new Lib.get_element_type(@type), @translation_unit
			end

			def num_elements
				Lib.get_num_elements(@type)
			end

			def array_element_type
				Type.new Lib.get_array_element_type(@type), @translation_unit
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

			def declaration
				Cursor.new Lib.get_type_declaration(@type), @translation_unit
			end

			def element_type
				Type.new Lib.get_array_element_type(@type), @translation_unit
			end

			def array_size
				Lib.get_array_size(@type)
			end
		end
	end
end
