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

require 'spec_helper'

describe Cursor do
	let(:cursor) { Index.new.parse_translation_unit(fixture_path("list.c")).cursor }
	let(:cursor_cxx) { Index.new.parse_translation_unit(fixture_path("test.cxx")).cursor }

	it "can be obtained from a translation unit" do
		cursor.should be_kind_of(Cursor)
		cursor.kind.should equal(:cursor_translation_unit)
		cursor.null?.should equal(false)
		cursor.translation_unit?.should equal(true)
	end

	it "returns the source location of the cursor" do
		location = cursor.location
		location.should be_kind_of(SourceLocation)
	end

	it "has an extent which is a SourceRange" do
		extent = cursor.extent
		extent.should be_kind_of(SourceRange)

		extent.start.file.should eq(fixture_path("list.c"))
		extent.start.line.should equal(1)

		extent.end.file.should eq(fixture_path("list.c"))
		extent.end.line.should equal(11)
	end

	it "returns the path of the translation unit for the translation unit cursor" do
		cursor.display_name.should eq(fixture_path("list.c"))
		cursor.spelling.should eq(fixture_path("list.c"))
	end

	it "allows us to visit its children" do
		counter = 0
		cursor.visit_children do |cursor, parent|
			counter += 1
			:recurse
		end
		counter.should_not equal(0)
	end

	describe "Null Cursor" do
		it "can be a null cursor" do
			Cursor.null_cursor.should be_kind_of(Cursor)
			Cursor.null_cursor.kind.should equal(:cursor_invalid_file)
		end

		it "is null?" do
			Cursor.null_cursor.null?.should equal(true)
		end

		it "is invalid?" do
			Cursor.null_cursor.invalid?.should equal(true)
		end

		it "compares as equal to another null cursor instance" do
			Cursor.null_cursor.should eq(Cursor.null_cursor)
		end

		it "should not equal a Translation Unit cursor" do
			Cursor.null_cursor.should_not eq(cursor)
		end
	end

	describe "Function Cursors" do
		let (:func) { find_first(cursor, :cursor_function) }

		it "is not invalid?" do
			func.invalid?.should equal(false)
		end

		it "can find the first function declaration" do
			func.should_not equal(nil)
			func.kind.should equal(:cursor_function)
		end

		it "has an extent representing the bounds of the function" do
			func.extent.should be_kind_of(SourceRange)
			func.extent.start.line.should equal(5)
			func.extent.end.line.should equal(5)
		end

		it "returns the name of the function" do
			func.spelling.should eq("sum")
			func.display_name.should eq("sum(union List *)")
		end
	end

	describe "Struct Cursors" do
		let (:struct) { find_first(cursor, :cursor_struct_decl) }

		it "can find the first struct" do
			struct.should_not equal(nil)
			struct.kind.should equal(:cursor_struct_decl)
		end

		it "has an extent representing the bounds of the struct" do
			struct.extent.start.line.should equal(1)
			struct.extent.end.line.should equal(4)
		end

		it "returns the name of the struct" do
			struct.spelling.should eq("List")
			struct.display_name.should eq("List")
		end

	end

	describe '#virtual_base?' do
		let(:virtual_base_cursor) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_cxx_base_specifier and parent.spelling == 'B' } }

		it 'checks cursor is virtual base' do
			virtual_base_cursor.virtual_base?.should equal true
		end
	end

	describe '#virtual?' do
		let(:virtual_cursor) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_cxx_method and child.spelling == 'func_a' } }

		it 'checks member function is virtual' do
			virtual_cursor.virtual?.should equal true
		end
	end

	describe '#pure_virtual?' do
		let(:pure_virtual_cursor) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_cxx_method and
				child.spelling == 'func_a' and parent.spelling == 'A' } }

		it 'checks member function is purely virtual' do
			pure_virtual_cursor.pure_virtual?.should equal true
		end
	end

	describe '#static?' do
		let(:static_method_cursor) { find_matching(cursor_cxx) { |child, parent|
			child.kind == :cursor_cxx_method and child.spelling == 'func_b' } }

		it 'checks cursor is static member function' do
			static_method_cursor.static?.should equal true
		end
	end

	describe '#enum_value' do
		let(:enum_value_cursor) { find_matching(cursor_cxx) { |child, parent|
			child.kind == :cursor_enum_constant_decl and child.spelling == 'EnumC' } }

		it 'returns enum value' do
			enum_value_cursor.enum_value.should equal 100
		end
	end

	describe '#dynamic_call?' do
		# TODO
	end

	describe '#specialized_template' do
		# TODO
	end

	describe '#canonical' do
		# TODO
	end

	describe '#definition' do
		# TODO
	end

	describe '#template_kind' do
		# TODO
	end

	describe '#access_specifier' do
		let(:access_specifier_cursor) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_cxx_method and child.spelling == 'func_d' } }

		it 'returns access specifier symbol' do
			access_specifier_cursor.access_specifier.should equal :private
		end
	end

	describe '#language' do
		let(:c_language_cursor) { find_matching(cursor) { |c, p| c.kind == :cursor_struct_decl } }
		let(:cxx_language_cursor) { find_matching(cursor_cxx) { |c, p| c.kind == :cursor_struct_decl } }

		it 'returns :c if the cursor language is C' do
			c_language_cursor.language.should equal :c
		end

		it 'returns :c_plus_plus if the cursor language is C++' do
			cxx_language_cursor.language.should equal :c_plus_plus
		end
	end
end
