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
			enum :kind, [:cursor_struct, 2,
				:cursor_enum_decl, 5,
				:cursor_enum_constant_decl, 7,
				:cursor_function, 8,
				:cursor_parm_decl, 10,
				:cursor_typedef_decl, 20,
				:cursor_invalid_file, 70,
				:cursor_translation_unit, 300
			]

			class CXCursor < FFI::Struct
				layout(
					:kind, :kind,
					:xdata, :int,
					:data, [:pointer, 3]
				)
			end

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

