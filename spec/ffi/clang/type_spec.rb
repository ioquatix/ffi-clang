# -*- coding: utf-8 -*-
# Copyright, 2013, by Carlos Martín Nieto <cmn@dwim.me>
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

describe Type do
	let(:cursor) { Index.new.parse_translation_unit(fixture_path("a.c")).cursor }
	let(:cursor_cxx) { Index.new.parse_translation_unit(fixture_path("test.cxx")).cursor }
	let(:cursor_list) { Index.new.parse_translation_unit(fixture_path("list.c")).cursor }
	let(:type) { find_first(cursor, :cursor_function).type }

	it "can tell us about the main function" do
		expect(type.variadic?).to equal(false)

		expect(type.num_arg_types).to equal(2)
		expect(type.arg_type(0).spelling).to eq("int")
		expect(type.arg_type(1).spelling).to eq("const char *")
		expect(type.result_type.spelling).to eq("int")
	end

  describe '#kind_spelling' do
    let(:kind_spelling_type) { find_matching(cursor_cxx) { |child, parent|
      child.kind == :cursor_typedef_decl and child.spelling == 'const_int_ptr'}.type }

    it 'returns type kind name with string' do
      expect(kind_spelling_type.kind_spelling).to eq 'Typedef'
    end
  end

  describe '#canonical' do
    let(:canonical_type) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_typedef_decl and child.spelling == 'const_int_ptr'
      }.type.canonical }

    it 'extracts typedef' do
      expect(canonical_type).to be_kind_of(Type)
      expect(canonical_type.kind).to be(:type_pointer)
      expect(canonical_type.spelling).to eq('const int *')
    end
  end

  describe '#pointee' do
    let(:pointee_type) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_typedef_decl and child.spelling == 'const_int_ptr'
      }.type.canonical.pointee }

    it 'gets pointee type of pointer, C++ reference' do
      expect(pointee_type).to be_kind_of(Type)
      expect(pointee_type.kind).to be(:type_int)
      expect(pointee_type.spelling).to eq('const int')
    end
  end

  describe '#const_qualified?' do
    let(:pointer_type) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_typedef_decl and child.spelling == 'const_int_ptr'
      }.type.canonical }

    let(:pointee_type) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_typedef_decl and child.spelling == 'const_int_ptr'
      }.type.canonical.pointee }

    it 'checks type is const qualified' do
      expect(pointee_type.const_qualified?).to equal true
    end

    it 'cannot check whether pointee type is const qualified' do
      expect(pointer_type.const_qualified?).to equal false
    end
  end

  describe '#volatile_qualified?' do
    let(:pointer_type) { find_matching(cursor) { |child, parent|
        child.kind == :cursor_variable and child.spelling == 'volatile_int_ptr'
      }.type }

    it 'checks type is volatile qualified' do
      expect(pointer_type.volatile_qualified?).to be true
    end
  end

  describe '#restrict_qualified?' do
    let(:pointer_type) { find_matching(cursor) { |child, parent|
        child.kind == :cursor_variable and child.spelling == 'restrict_int_ptr'
      }.type }

    it 'checks type is restrict qualified' do
      expect(pointer_type.restrict_qualified?).to be true
    end
  end

  describe '#element_type' do
    let(:array_type) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_variable and child.spelling == 'int_array'
      }.type }

    it 'returns the element type of the array type' do
      expect(array_type.element_type).to be_kind_of(Type)
      expect(array_type.element_type.kind).to eq(:type_int)
    end
  end

  describe '#num_elements' do
    let(:array_type) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_variable and child.spelling == 'int_array'
      }.type }

    it 'returns the number of elements of the array' do
      expect(array_type.num_elements).to eq(8)
    end
  end

  describe '#array_element_type' do
    let(:array_type) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_variable and child.spelling == 'int_array'
      }.type }

    it 'returns the array element type of the array type' do
      expect(array_type.array_element_type).to be_kind_of(Type)
      expect(array_type.array_element_type.kind).to eq(:type_int)
    end
  end

  describe '#array_size' do
    let(:array_type) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_variable and child.spelling == 'int_array'
      }.type }

    it 'returns the number of elements of the array' do
      expect(array_type.array_size).to eq(8)
    end
  end

  describe '#alignof' do
    let(:array_type) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_variable and child.spelling == 'int_array'
      }.type }

    it 'returns the alignment of the type in bytes' do
      expect(array_type.alignof).to be_kind_of(Integer)
      expect(array_type.alignof).to be > 0
    end
  end

  describe '#sizeof' do
    let(:array_type) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_variable and child.spelling == 'int_array'
      }.type }

    it 'returns the size of the type in bytes' do
      expect(array_type.sizeof).to be_kind_of(Integer)
      expect(array_type.sizeof).to be(32)
    end
  end

  describe '#offsetof' do
    let(:struct) { find_matching(cursor_list) { |child, parent|
        child.kind == :cursor_struct and child.spelling == 'List'
      }.type }

    it 'returns the offset of a field in a record of the type in bits' do
      expect(struct.offsetof('Next')).to be_kind_of(Integer)
      expect(struct.offsetof('Next')).to be(64)
    end
  end

  describe '#ref_qualifier' do
    let(:lvalue) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_cxx_method and child.spelling == 'func_lvalue_ref'
      }.type }
    let(:rvalue) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_cxx_method and child.spelling == 'func_rvalue_ref'
      }.type }
    let(:none) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_cxx_method and child.spelling == 'func_none'
      }.type }

    it 'returns :ref_qualifier_lvalue the type is ref-qualified with lvalue' do
      expect(lvalue.ref_qualifier).to be(:ref_qualifier_lvalue)
    end

    it 'returns :ref_qualifier_rvalue the type is ref-qualified with rvalue' do
      expect(rvalue.ref_qualifier).to be(:ref_qualifier_rvalue)
    end

    it 'returns :ref_qualifier_none the type is not ref-qualified' do
      expect(none.ref_qualifier).to be(:ref_qualifier_none)
    end
  end

  describe '#pod?' do
    let(:struct) { find_matching(cursor_list) { |child, parent|
        child.kind == :cursor_struct and child.spelling == 'List'
      }.type }

    it 'returns true if the type is a POD type' do
      expect(struct.pod?).to be true
    end
  end

  describe '#class_type' do
    let(:member_pointer) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_variable and child.spelling == 'member_pointer'
      }.type }

    it 'returns the class type of the member pointer type' do
      expect(member_pointer.class_type).to be_kind_of(Type)
      expect(member_pointer.class_type.kind).to be(:type_record)
      expect(member_pointer.class_type.spelling).to eq('A')
    end
  end

  describe '#declaration' do
    let(:struct_ref) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_type_ref and child.spelling == 'struct D'
      }.type }
    let(:struct_decl) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_struct and child.spelling == 'D'
      } }
    let(:no_decl) { find_first(cursor_cxx, :cursor_cxx_method).type }

    it 'returns the class type of the member pointer type' do
      expect(struct_ref.declaration).to be_kind_of(Cursor)
      expect(struct_ref.declaration.kind).to be(:cursor_struct)
      expect(struct_ref.declaration).to eq(struct_decl)
    end

    it 'returns :cursor_no_decl_found if the type has no declaration' do
      expect(no_decl.declaration).to be_kind_of(Cursor)
      expect(no_decl.declaration.kind).to be(:cursor_no_decl_found)
    end
  end

  describe '#calling_conv' do
    let(:function) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_function and child.spelling == 'f_variadic'
      }.type }

    it 'returns the calling convention associated with the function type' do
      expect(function.calling_conv).to be(:calling_conv_c)
    end
  end

  describe '#==' do
    let(:type_decl) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_field_decl and child.spelling == 'int_member_a'
      }.type }
    let(:type_ref) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_decl_ref_expr and child.spelling == 'int_member_a'
      }.type }

    it 'checks if two types represent the same type' do
      expect(type_decl == type_ref).to be true
    end
  end
end
