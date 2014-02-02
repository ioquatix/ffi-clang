# -*- coding: utf-8 -*-
# Copyright, 2013, by Carlos Martín Nieto <cmn@dwim.me>
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

describe Type do
	let(:cursor) { Index.new.parse_translation_unit(fixture_path("a.c")).cursor }
	let(:cursor_cxx) { Index.new.parse_translation_unit(fixture_path("test.cxx")).cursor }
	let(:type) { find_first(cursor, :cursor_function).type }

	it "can tell us about the main function", from_3_3: true do
		type.variadic?.should equal(false)

		type.num_arg_types.should equal(2)
		type.arg_type(0).spelling.should eq("int")
		type.arg_type(1).spelling.should eq("const char *")
		type.result_type.spelling.should eq("int")
	end

  describe '#kind_spelling' do
    let(:kind_spelling_type) { find_matching(cursor_cxx) { |child, parent|
      child.kind == :cursor_typedef_decl and child.spelling == 'const_int_ptr'}.type }

    it 'returns type kind name with string' do
      kind_spelling_type.kind_spelling.should eq 'Typedef'
    end
  end

  describe '#canonical' do
    let(:canonical_type) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_typedef_decl and child.spelling == 'const_int_ptr'
      }.type.canonical }

    it 'extracts typedef', upto_3_2: true do
      expect(canonical_type).to be_kind_of(Type)
      expect(canonical_type.kind).to be(:type_pointer)
    end

    it 'extracts typedef', from_3_3: true do
      expect(canonical_type).to be_kind_of(Type)
      expect(canonical_type.kind).to be(:type_pointer)
      expect(canonical_type.spelling).to eq('const int *')
    end
  end

  describe '#pointee' do
    let(:pointee_type) { find_matching(cursor_cxx) { |child, parent|
        child.kind == :cursor_typedef_decl and child.spelling == 'const_int_ptr'
      }.type.canonical.pointee }

    it 'gets pointee type of pointer, C++ reference', upto_3_2: true do
      expect(pointee_type).to be_kind_of(Type)
      expect(pointee_type.kind).to be(:type_int)
    end

    it 'gets pointee type of pointer, C++ reference', from_3_3: true do
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
      pointee_type.const_qualified?.should equal true
    end

    it 'cannot check whether pointee type is const qualified' do
      pointer_type.const_qualified?.should equal false
    end
  end
end
