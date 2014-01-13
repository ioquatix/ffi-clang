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
	let(:cursor_canon) { Index.new.parse_translation_unit(fixture_path("canonical.c")).cursor }

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
		let (:struct) { find_first(cursor, :cursor_struct) }

		it "can find the first struct" do
			struct.should_not equal(nil)
			struct.kind.should equal(:cursor_struct)
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
		let (:structs) { find_all(cursor_canon, :cursor_struct) }

		it "mathes 3 cursors" do
			structs.size.should eq(3)
		end

		it "refers the first cursor as canonical one" do
			structs[0].canonical.should eq(structs[0])
			structs[1].canonical.should eq(structs[0])
			structs[2].canonical.should eq(structs[0])
		end
	end

	describe '#definition' do
		let (:structs) { find_all(cursor_canon, :cursor_struct) }

		it "mathes 3 cursors" do
			structs.size.should eq(3)
		end

		it "refers the third cursor as definition one" do
			structs[0].definition.should eq(structs[2])
			structs[1].definition.should eq(structs[2])
			structs[2].definition.should eq(structs[2])
		end
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
		let(:c_language_cursor) { find_matching(cursor) { |c, p| c.kind == :cursor_struct } }
		let(:cxx_language_cursor) { find_matching(cursor_cxx) { |c, p| c.kind == :cursor_struct } }

		it 'returns :c if the cursor language is C' do
			c_language_cursor.language.should equal :c
		end

		it 'returns :c_plus_plus if the cursor language is C++' do
			cxx_language_cursor.language.should equal :c_plus_plus
		end
	end

	describe '#translation_unit' do
		let (:struct) { find_first(cursor, :cursor_struct) }

		it "can find the first struct" do
			struct.should_not equal(nil)
		end

		it "returns the translation unit that a cursor originated from" do
			struct.translation_unit.should be_kind_of(TranslationUnit)
		end
	end

	describe '#linkage' do
		let (:ref) { find_first(cursor, :cursor_type_ref) }
		let (:func) { find_first(cursor, :cursor_function) }

		it "returns :external if the cursor is non-static function" do
			func.linkage.should equal :external
		end

		it "returns :invalid if the cursor does not have linkage" do
			ref.linkage.should equal :invalid
		end
	end

	describe '#semantic_parent' do
		let(:parent) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_cxx_method and child.spelling == 'func_d' and parent.spelling != 'D' } }

		it 'returns base class as semantic parent' do
			parent.semantic_parent.spelling.should eq('D')
		end
	end

	describe '#lexical_parent' do
		let(:parent) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_cxx_method and child.spelling == 'func_d' and parent.spelling != 'D' } }

		it 'returns translation unit as lexical parent' do
			parent.lexical_parent.kind.should eq(:cursor_translation_unit)
		end
	end

	describe '#included_file' do
		#TODO
	end

	describe '#definition?' do
		let (:struct) { find_all(cursor_canon, :cursor_struct).at(2) }

		it "checks cursor is a definition" do
			struct.definition?.should be_true
		end
	end

	describe '#usr' do
		let (:func) { find_first(cursor, :cursor_function) }

		it "returns something in string" do
			func.usr.should be_kind_of(String)
		end
	end

	describe '#variadic?' do
		let(:func) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_function and child.spelling == 'f_variadic' } }

		it "checks cursor is a variadic function" do
			func.variadic?.should be_true
		end
	end

	describe '#referenced' do
		let(:struct) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_struct and child.spelling == 'A' } }
		let(:ref) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_type_ref and child.spelling == 'struct A' } }

		it "returns a cursor that this cursor references" do
			ref.referenced.should eq(struct)
		end

	end

	describe '#hash' do
		let (:func) { find_first(cursor, :cursor_function) }

		it "computes hash for the cursor" do
			func.hash.should be_kind_of(Fixnum)
		end
	end

	describe '#availability' do
		let (:func) { find_first(cursor, :cursor_function) }

		it "returns :available for the cursor availability" do
			func.availability.should equal(:available)
		end
	end

	describe '#type' do
		let (:field) { find_first(cursor, :cursor_field_decl) }

		it "returns type for the cursor" do
			field.type.should be_kind_of(Type)
			field.type.kind.should equal(:type_int)
		end
	end

	describe '#underlying_type' do
		let (:typedef) { find_first(cursor_cxx, :cursor_typedef_decl) }

		it "returns type that the cursor type is underlying" do
			typedef.underlying_type.should be_kind_of(Type)
			typedef.underlying_type.kind.should equal(:type_pointer)
		end
	end

	describe '#enum_decl_integer_type' do
		#TODO
	end

	describe '#platform_availability' do
		#TODO
	end

	describe '#get_overridden_cursors' do
		#TODO
	end
end
