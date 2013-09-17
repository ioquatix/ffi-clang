# Copyright, 2010-2012 by Jari Bakken.
# Copyright, 2013, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'ffi/clang/lib/cursor'
require 'ffi/clang/source_location'
require 'ffi/clang/comment'
require 'ffi/clang/type'

module FFI
	module Clang
		class Cursor
			def self.null_cursor
				Cursor.new Lib.get_null_cursor
			end

			def initialize( cxcursor )
				@cursor = cxcursor
			end

			def null?
				Lib.cursor_is_null(@cursor) != 0
			end

			def raw_comment_text
				Lib.extract_string Lib.cursor_get_raw_comment_text(@cursor)
			end

			def comment
				Comment.build_from Lib.cursor_get_parsed_comment(@cursor)
			end

			def declaration?
				Lib.is_declaration(kind) != 0
			end

			def reference?
				Lib.is_reference(kind) != 0
			end

			def expression?
				Lib.is_expression(kind) != 0
			end

			def statement?
				Lib.is_statement(kind) != 0
			end

			def attribute?
				Lib.is_attribute(kind) != 0
			end

			def invalid?
				Lib.is_invalid(kind) != 0
			end

			def translation_unit?
				Lib.is_translation_unit(kind) != 0
			end

			def preprocessing?
				Lib.is_preprocessing(kind) != 0
			end

			def unexposed?
				Lib.is_unexposed(kind) != 0
			end

			def location
				SourceLocation.new(Lib.get_cursor_location(@cursor))
			end

			def extent
				SourceRange.new(Lib.get_cursor_extent(@cursor))
			end

			def display_name
				Lib.extract_string Lib.get_cursor_display_name(@cursor)
			end

			def spelling
				Lib.extract_string Lib.get_cursor_spelling(@cursor)
			end

			def kind
				@cursor[:kind]
			end

			def type
				Type.new Lib.get_cursor_type(@cursor)
			end

			def result_type
				Type.new Lib.get_cursor_result_type(@cursor)
			end

			def virtual_base?
				Lib.is_virtual_base(@cursor) != 0
			end

			def dynamic_call?
				Lib.is_dynamic_call(@cursor) != 0
			end

			def static?
				Lib.cxx_method_is_static(@cursor) != 0
			end

			def virtual?
				Lib.cxx_method_is_virtual(@cursor) != 0
			end

			def pure_virtual?
				Lib.cxx_method_is_pure_virtual(@cursor) != 0
			end

			def enum_value
				Lib.get_enum_value @cursor
			end

			def specialized_template
				Cursor.new Lib.get_specialized_cursor_template @cursor
			end

			def canonical
				Cursor.new Lib.get_canonical_cursor @cursor
			end

			def definition
				Cursor.new Lib.get_cursor_definition @cursor
			end

			def template_kind
				Lib.get_template_cursor_kind @cursor
			end

			def access_specifier
				Lib.get_cxx_access_specifier @cursor
			end

			def language
				Lib.get_language @cursor
			end

			def visit_children(&block)
				adapter = Proc.new do | cxcursor, parent_cursor, unused |
					block.call Cursor.new(cxcursor), Cursor.new(parent_cursor)
				end
				
				Lib.visit_children(@cursor, adapter, nil)
			end

			attr_reader :cursor

			def ==(other)
				Lib.are_equal(@cursor, other.cursor) != 0
			end
		end
	end
end
