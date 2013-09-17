# Copyright, 2010-2012 by Jari Bakken.
# Copyright, 2013, by Samuel G. D. Williams. <http://www.codeotaku.com>
# Copyright, 2013, by Garry C. Marshall. <http://www.meaningfulname.net>
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

require 'ffi/clang/lib/translation_unit'
require 'ffi/clang/lib/diagnostic'
require 'ffi/clang/lib/comment'
require 'ffi/clang/lib/type'

module FFI
	module Clang
		module Lib
			enum :kind, [:cursor_unexposed_decl, 1,
				:cursor_struct_decl, 2,
				:cursor_class_decl, 4,
				:cursor_enum_decl, 5,
				:cursor_enum_constant_decl, 7,
				:cursor_function, 8,
				:cursor_var_decl, 9,
				:cursor_parm_decl, 10,
				:cursor_typedef_decl, 20,
				:cursor_cxx_method, 21,
				:cursor_namespace, 22,
				:cursor_ctor, 24,
				:cursor_dtor, 25,
				:cursor_template_type_parameter, 27,
				:cursor_template_template_parameter, 29,
				:cursor_function_template, 30,
				:cursor_class_template, 31,
				:cursor_class_template_partial_specialization, 32,
				:cursor_cxx_access_specifier, 39,
				:cursor_typeref, 43,
				:cursor_cxx_base_specifier, 44,
				:cursor_template_ref, 45,
				:cursor_member_ref, 47,
				:cursor_invalid_file, 70,
				:cursor_no_decl_found, 71,
				:cursor_first_expr, 100,
				:cursor_decl_ref_expr, 101,
				:cursor_member_ref_expr, 102,
				:cursor_integer_literal, 106,
				:cursor_unary_operator, 112,
				:cursor_compound_stmt, 202,
				:cursor_return_stmt, 214,
				:cursor_translation_unit, 300
			]

			class CXCursor < FFI::Struct
				layout(
					:kind, :kind,
					:xdata, :int,
					:data, [:pointer, 3]
				)
			end


			enum :cxx_access_specifier, [:invalid, :public, :protected, :private]
			attach_function :get_cxx_access_specifier, :clang_getCXXAccessSpecifier, [CXCursor.by_value], :cxx_access_specifier

			attach_function :get_enum_value, :clang_getEnumConstantDeclValue, [CXCursor.by_value], :long_long

			attach_function :is_virtual_base, :clang_isVirtualBase, [CXCursor.by_value], :uint
			attach_function :is_dynamic_call, :clang_Cursor_isDynamicCall, [CXCursor.by_value], :uint
			attach_function :cxx_method_is_static, :clang_CXXMethod_isStatic, [CXCursor.by_value], :uint
			attach_function :cxx_method_is_virtual, :clang_CXXMethod_isVirtual, [CXCursor.by_value], :uint
			attach_function :cxx_method_is_pure_virtual, :clang_CXXMethod_isPureVirtual, [CXCursor.by_value], :uint

			enum :language_kind, [:invalid, :c, :obj_c, :c_plus_plus]
			attach_function :get_language, :clang_getCursorLanguage, [CXCursor.by_value], :language_kind

			attach_function :get_canonical_cursor, :clang_getCanonicalCursor, [CXCursor.by_value], CXCursor.by_value
			attach_function :get_cursor_definition, :clang_getCursorDefinition, [CXCursor.by_value], CXCursor.by_value
			attach_function :get_specialized_cursor_template, :clang_getSpecializedCursorTemplate, [CXCursor.by_value], CXCursor.by_value
			attach_function :get_template_cursor_kind, :clang_getTemplateCursorKind, [CXCursor.by_value], :kind

			attach_function :get_translation_unit_cursor, :clang_getTranslationUnitCursor, [:CXTranslationUnit], CXCursor.by_value

			attach_function :get_null_cursor, :clang_getNullCursor, [], CXCursor.by_value

			attach_function :cursor_is_null, :clang_Cursor_isNull, [CXCursor.by_value], :int

			attach_function :cursor_get_raw_comment_text, :clang_Cursor_getRawCommentText, [CXCursor.by_value], CXString.by_value
			attach_function :cursor_get_parsed_comment, :clang_Cursor_getParsedComment, [CXCursor.by_value], CXComment.by_value

			attach_function :get_cursor_location, :clang_getCursorLocation, [CXCursor.by_value], CXSourceLocation.by_value
			attach_function :get_cursor_extent, :clang_getCursorExtent, [CXCursor.by_value], CXSourceRange.by_value
			attach_function :get_cursor_display_name, :clang_getCursorDisplayName, [CXCursor.by_value], CXString.by_value
			attach_function :get_cursor_spelling, :clang_getCursorSpelling, [CXCursor.by_value], CXString.by_value

			attach_function :are_equal, :clang_equalCursors, [CXCursor.by_value, CXCursor.by_value], :uint

			attach_function :is_declaration, :clang_isDeclaration, [:kind], :uint
			attach_function :is_reference, :clang_isReference, [:kind], :uint
			attach_function :is_expression, :clang_isExpression, [:kind], :uint
			attach_function :is_statement, :clang_isStatement, [:kind], :uint
			attach_function :is_attribute, :clang_isAttribute, [:kind], :uint
			attach_function :is_invalid, :clang_isInvalid, [:kind], :uint
			attach_function :is_translation_unit, :clang_isTranslationUnit, [:kind], :uint
			attach_function :is_preprocessing, :clang_isPreprocessing, [:kind], :uint
			attach_function :is_unexposed, :clang_isUnexposed, [:kind], :uint

			enum :child_visit_result, [:break, :continue, :recurse]

			callback :visit_children_function, [CXCursor.by_value, CXCursor.by_value, :pointer], :child_visit_result
			attach_function :visit_children, :clang_visitChildren, [CXCursor.by_value, :visit_children_function, :pointer], :uint

			attach_function :get_cursor_type, :clang_getCursorType, [CXCursor.by_value], CXType.by_value
			attach_function :get_cursor_result_type, :clang_getCursorResultType, [CXCursor.by_value], CXType.by_value

		end
	end
end
