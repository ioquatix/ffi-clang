# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2013-2025, by Samuel Williams.
# Copyright, 2013, by Takeshi Watanabe.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2024, by Charlie Savage.

describe FFI::Clang::Types::Type do
	let(:cursor) {Index.new.parse_translation_unit(fixture_path("a.c")).cursor}
	let(:cursor_cxx) {Index.new.parse_translation_unit(fixture_path("test.cxx")).cursor}
	let(:cursor_list) {Index.new.parse_translation_unit(fixture_path("list.c")).cursor}
	let(:type) {find_by_kind(cursor, :cursor_function).type}
	
	it "can tell us about the main function" do
		expect(type.variadic?).to equal(false)
		
		expect(type.args_size).to equal(2)
		expect(type.arg_type(0).spelling).to eq("int")
		expect(type.arg_type(1).spelling).to eq("const char *")
		expect(type.result_type.spelling).to eq("int")
	end
	
	describe "#kind_spelling" do
		let(:kind_spelling_type) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_typedef_decl and child.spelling == "const_int_ptr"
			end.type
		end
		
		it "returns type kind name with string" do
			expect(kind_spelling_type.kind_spelling).to eq "Typedef"
		end
	end
	
	describe "#canonical" do
		let(:canonical_type) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_typedef_decl and child.spelling == "const_int_ptr"
			end.type.canonical
		end
		
		it "extracts typedef" do
			expect(canonical_type).to be_kind_of(Types::Pointer)
			expect(canonical_type.kind).to be(:type_pointer)
			expect(canonical_type.spelling).to eq("const int *")
		end
	end
	
	describe "#pointee" do
		let(:pointee_type) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_typedef_decl and child.spelling == "const_int_ptr"
			end.type.canonical.pointee
		end
		
		it "gets pointee type of pointer, C++ reference" do
			expect(pointee_type).to be_kind_of(Types::Type)
			expect(pointee_type.kind).to be(:type_int)
			expect(pointee_type.spelling).to eq("const int")
		end
	end
	
	describe "#function_type" do
		let(:reference_type) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_cxx_method and child.spelling == "takesARef"
			end.type
		end
		
		it "iterates arg_types" do
			expect(reference_type).to be_kind_of(Types::Function)
			expect(reference_type.arg_types.to_a).to be_kind_of(Array)
			expect(reference_type.arg_types.to_a.size).to eq(2)
		end
		
		it "supports non-reference arg_types" do
			args_types = reference_type.arg_types.to_a
			expect(args_types[0].kind).to eq(:type_lvalue_ref)
			expect(args_types[0].non_reference_type.kind).to eq(:type_int)
			expect(args_types[1].kind).to eq(:type_rvalue_ref)
			expect(args_types[1].non_reference_type.kind).to eq(:type_float)
		end
	end
	
	describe "#const_qualified?" do
		let(:pointer_type) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_typedef_decl and child.spelling == "const_int_ptr"
			end.type.canonical
		end
		
		let(:pointee_type) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_typedef_decl and child.spelling == "const_int_ptr"
			end.type.canonical.pointee
		end
		
		it "checks type is const qualified" do
			expect(pointee_type.const_qualified?).to equal true
		end
		
		it "cannot check whether pointee type is const qualified" do
			expect(pointer_type.const_qualified?).to equal false
		end
	end
	
	describe "#volatile_qualified?" do
		let(:pointer_type) do
			find_matching(cursor) do |child, parent|
				child.kind == :cursor_variable and child.spelling == "volatile_int_ptr"
			end.type
		end
		
		it "checks type is volatile qualified" do
			expect(pointer_type.volatile_qualified?).to be true
		end
	end
	
	describe "#restrict_qualified?" do
		let(:pointer_type) do
			find_matching(cursor) do |child, parent|
				child.kind == :cursor_variable and child.spelling == "restrict_int_ptr"
			end.type
		end
		
		it "checks type is restrict qualified" do
			expect(pointer_type.restrict_qualified?).to be true
		end
	end
	
	describe "#element_type" do
		let(:array_type) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_variable and child.spelling == "int_array"
			end.type
		end
		
		it "returns the element type of the array type" do
			expect(array_type.element_type).to be_kind_of(Types::Type)
			expect(array_type.element_type.kind).to eq(:type_int)
		end
	end
	
	describe "#num_elements" do
		let(:array_type) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_variable and child.spelling == "int_array"
			end.type
		end
		
		it "returns the number of elements of the array" do
			expect(array_type.size).to eq(8)
		end
	end
	
	describe "#array_element_type" do
		let(:array_type) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_variable and child.spelling == "int_array"
			end.type
		end
		
		it "returns the array element type of the array type" do
			expect(array_type.element_type).to be_kind_of(Types::Type)
			expect(array_type.element_type.kind).to eq(:type_int)
		end
	end
	
	describe "#array_size" do
		let(:array_type) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_variable and child.spelling == "int_array"
			end.type
		end
		
		it "returns the number of elements of the array" do
			expect(array_type.size).to eq(8)
		end
	end
	
	describe "#alignof" do
		let(:array_type) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_variable and child.spelling == "int_array"
			end.type
		end
		
		it "returns the alignment of the type in bytes" do
			expect(array_type.alignof).to be_kind_of(Integer)
			expect(array_type.alignof).to be > 0
		end
	end
	
	describe "#sizeof" do
		let(:array_type) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_variable and child.spelling == "int_array"
			end.type
		end
		
		it "returns the size of the type in bytes" do
			expect(array_type.sizeof).to be_kind_of(Integer)
			expect(array_type.sizeof).to be(32)
		end
	end
	
	describe "#offsetof" do
		let(:struct) do
			find_matching(cursor_list) do |child, parent|
				child.kind == :cursor_struct and child.spelling == "List"
			end.type
		end
		
		it "returns the offset of a field in a record of the type in bits" do
			expect(struct.offsetof("Next")).to be_kind_of(Integer)
			expect(struct.offsetof("Next")).to be(64)
		end
	end
	
	describe "#ref_qualifier" do
		let(:lvalue) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_cxx_method and child.spelling == "func_lvalue_ref"
			end.type
		end
		let(:rvalue) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_cxx_method and child.spelling == "func_rvalue_ref"
			end.type
		end
		let(:none) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_cxx_method and child.spelling == "func_none"
			end.type
		end
		
		it "returns :ref_qualifier_lvalue the type is ref-qualified with lvalue" do
			expect(lvalue.ref_qualifier).to be(:ref_qualifier_lvalue)
		end
		
		it "returns :ref_qualifier_rvalue the type is ref-qualified with rvalue" do
			expect(rvalue.ref_qualifier).to be(:ref_qualifier_rvalue)
		end
		
		it "returns :ref_qualifier_none the type is not ref-qualified" do
			expect(none.ref_qualifier).to be(:ref_qualifier_none)
		end
	end
	
	describe "#pod?" do
		let(:struct) do
			find_matching(cursor_list) do |child, parent|
				child.kind == :cursor_struct and child.spelling == "List"
			end.type
		end
		
		it "returns true if the type is a POD type" do
			expect(struct.pod?).to be true
		end
	end
	
	describe "#class_type" do
		let(:member_pointer) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_variable and child.spelling == "member_pointer"
			end.type
		end
		
		it "returns the class type of the member pointer type" do
			expect(member_pointer.class_type).to be_kind_of(Types::Record)
			expect(member_pointer.class_type.kind).to be(:type_record)
			expect(member_pointer.class_type.spelling).to eq("A")
		end
	end
	
	describe "#declaration" do
		let(:struct_ref) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_type_ref and child.spelling == "struct D"
			end.type
		end
		let(:struct_decl) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_struct and child.spelling == "D"
			end
		end
		let(:no_decl) {find_by_kind(cursor_cxx, :cursor_cxx_method).type}
		
		it "returns the class type of the member pointer type" do
			expect(struct_ref.declaration).to be_kind_of(Cursor)
			expect(struct_ref.declaration.kind).to be(:cursor_struct)
			expect(struct_ref.declaration).to eq(struct_decl)
		end
		
		it "returns :cursor_no_decl_found if the type has no declaration" do
			expect(no_decl.declaration).to be_kind_of(Cursor)
			expect(no_decl.declaration.kind).to be(:cursor_no_decl_found)
		end
	end
	
	describe "#calling_conv" do
		let(:function) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_function and child.spelling == "f_variadic"
			end.type
		end
		
		it "returns the calling convention associated with the function type" do
			expect(function.calling_conv).to be(:calling_conv_c)
		end
	end
	
	describe "#exception_specification" do
		let(:exception_yes_1) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_cxx_method and child.spelling == "exceptionYes1"
			end.type
		end
		
		it "can create exceptions 1" do
			expect(exception_yes_1.exception_specification).to be(:none)
		end
		
		let(:exception_yes_2) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_cxx_method and child.spelling == "exceptionYes2"
			end.type
		end
		
		it "can create exceptions 2" do
			expect(exception_yes_2.exception_specification).to be(:computed_noexcept)
		end
		
		let(:exception_no_1) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_cxx_method and child.spelling == "exceptionNo1"
			end.type
		end
		
		it "cannot create exceptions 1" do
			expect(exception_no_1.exception_specification).to be(:basic_noexcept)
		end
		
		let(:exception_no_2) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_cxx_method and child.spelling == "exceptionNo2"
			end.type
		end
		
		it "cannot create exceptions 2" do
			expect(exception_no_2.exception_specification).to be(:computed_noexcept)
		end
		
		let(:exception_throw) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_cxx_method and child.spelling == "exceptionThrow"
			end.type
		end
		
		it "can create throw exceptions" do
			expect(exception_throw.exception_specification).to be(:dynamic_none)
		end
	end
	
	describe "#==" do
		let(:type_decl) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_field_decl and child.spelling == "int_member_a"
			end.type
		end
		
		let(:type_ref) do
			find_matching(cursor_cxx) do |child, parent|
				child.kind == :cursor_decl_ref_expr and child.spelling == "int_member_a"
			end.type
		end
		
		it "checks if two types represent the same type" do
			expect(type_decl == type_ref).to be true
		end
	end
end
