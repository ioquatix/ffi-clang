# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2013, by Garry Marshall.
# Copyright, 2013-2024, by Samuel Williams.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2013, by Takeshi Watanabe.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2014, by George Pimm.
# Copyright, 2017, by Cameron Dutro.
# Copyright, 2019, by Michael Metivier.
# Copyright, 2023-2024, by Charlie Savage.

describe "Function Call Cursors" do
	let(:translation_unit) {Index.new.parse_translation_unit(fixture_path("class.cpp"))}
	let(:cursor) {translation_unit.cursor}
	let(:call) {find_by_kind(cursor, :cursor_call_expr)}

	it "should parse correctly" do
		expect(translation_unit.diagnostics).to be_empty
	end

	it "should find a method call" do
		expect(call).to_not be_nil
	end
end


describe FFI::Clang::Cursor do
	let(:translation_unit) {Index.new.parse_translation_unit(fixture_path("class.cpp"))}
	let(:cursor) {translation_unit.cursor}
	let (:class1) { find_all_by_kind(cursor, :cursor_class_decl)[0] }
	let (:class2) { find_all_by_kind(cursor, :cursor_class_decl)[1] }
	let (:class3) { find_all_by_kind(cursor, :cursor_class_decl)[2] }

	it "can find the first class" do
		expect(class1).not_to equal(nil)
		expect(class1.kind).to equal(:cursor_class_decl)
	end

	it "returns the name of the class" do
		expect(class1.spelling).to eq("MyClass1")
		expect(class1.display_name).to eq("MyClass1")
		expect(class2.spelling).to eq("MyClass2")
		expect(class2.display_name).to eq("MyClass2")
		expect(class3.spelling).to eq("MyClass3")
		expect(class3.display_name).to eq("MyClass3")
	end

	it "has constructors" do
		constructors = find_all_by_kind(class2, :cursor_constructor)
		expect(constructors.length).to eq(5)

		expect(constructors[0].default_constructor?).to eq(true)
		expect(constructors[0].copy_constructor?).to eq(false)
		expect(constructors[0].move_constructor?).to eq(false)
		expect(constructors[0].converting_constructor?).to eq(false)

		expect(constructors[1].default_constructor?).to eq(false)
		expect(constructors[1].copy_constructor?).to eq(false)
		expect(constructors[1].move_constructor?).to eq(false)
		expect(constructors[1].converting_constructor?).to eq(true)

		expect(constructors[2].default_constructor?).to eq(false)
		expect(constructors[2].copy_constructor?).to eq(false)
		expect(constructors[2].move_constructor?).to eq(false)
		expect(constructors[2].converting_constructor?).to eq(false)

		expect(constructors[3].default_constructor?).to eq(false)
		expect(constructors[3].copy_constructor?).to eq(true)
		expect(constructors[3].move_constructor?).to eq(false)
		expect(constructors[3].converting_constructor?).to eq(true)
		expect(constructors[3].defaulted?).to eq(true)

		expect(constructors[4].default_constructor?).to eq(false)
		expect(constructors[4].copy_constructor?).to eq(false)
		expect(constructors[4].move_constructor?).to eq(true)
		expect(constructors[4].converting_constructor?).to eq(true)
		expect(constructors[3].defaulted?).to eq(true)
	end

	it "has destructors" do
		constructors = find_all_by_kind(class2, :cursor_constructor)
		expect(constructors.length).to eq(5)
	end

	it "class is abstract" do
		expect(class1.abstract?).to eq(false)
		expect(class2.abstract?).to eq(false)
		expect(class3.abstract?).to eq(true)
	end

	it "field is mutable abstract" do
		fields = find_all_by_kind(class3, :cursor_field_decl)

		field = fields[0]
		expect(field.mutable?).to eq(true)
	end
end


describe Cursor do
	let(:cursor) { Index.new.parse_translation_unit(fixture_path("list.c")).cursor }
	let(:cursor_cxx) { Index.new.parse_translation_unit(fixture_path("test.cxx")).cursor }
	let(:cursor_canon) { Index.new.parse_translation_unit(fixture_path("canonical.c")).cursor }
	let(:cursor_pp) { Index.new.parse_translation_unit(fixture_path("docs.c"),[],[],[:detailed_preprocessing_record]).cursor }
	let(:cursor_forward) { Index.new.parse_translation_unit(fixture_path("forward.h")).cursor }
	let(:cursor_anonymous) { Index.new.parse_translation_unit(fixture_path("anonymous.h")).cursor }

	it "can be obtained from a translation unit" do
		expect(cursor).to be_kind_of(Cursor)
		expect(cursor.kind).to equal(:cursor_translation_unit)
		expect(cursor.null?).to equal(false)
		expect(cursor.translation_unit?).to equal(true)
	end

	it "returns the source location of the cursor" do
		location = cursor.location
		expect(location).to be_kind_of(SourceLocation)
	end

	describe '#extent' do
		let(:extent) { cursor.extent }
		it "has an extent which is a SourceRange" do
			expect(extent).to be_kind_of(SourceRange)
		end

		it 'has filename and posion at start point' do
			expect(extent.start.file).to eq(fixture_path("list.c"))
			expect(extent.start.line).to equal(1)
		end

		it 'has filename and posion at end point' do
			expect(extent.end.file).to eq(fixture_path("list.c"))
			expect(extent.end.line).to equal(12)
		end
	end

	it "returns the path of the translation unit for the translation unit cursor" do
		expect(cursor.display_name).to eq(fixture_path("list.c"))
		expect(cursor.spelling).to eq(fixture_path("list.c"))
	end

	it "allows us to visit its children" do
		counter = 0
		cursor.each do |cursor, parent|
			counter += 1
			:recurse
		end
		expect(counter).not_to equal(0)
	end
	
	describe "#visit_children" do
		it "allows us to visit its children" do
			cursor.visit_children do |cursor, parent|
				counter += 1
			end
			
			expect(counter).not_to equal(0)
		end
	end

	describe "Null Cursor" do
		it "can be a null cursor" do
			expect(Cursor.null_cursor).to be_kind_of(Cursor)
			expect(Cursor.null_cursor.kind).to equal(:cursor_invalid_file)
		end

		it "is null?" do
			expect(Cursor.null_cursor.null?).to equal(true)
		end

		it "is invalid?" do
			expect(Cursor.null_cursor.invalid?).to equal(true)
		end

		it "compares as equal to another null cursor instance" do
			expect(Cursor.null_cursor).to eq(Cursor.null_cursor)
		end

		it "should not equal a Translation Unit cursor" do
			expect(Cursor.null_cursor).not_to eq(cursor)
		end
	end

	describe "Function Cursors" do
		let (:func) { find_by_kind(cursor, :cursor_function) }

		it "is not invalid?" do
			expect(func.invalid?).to equal(false)
		end

		it "can find the first function declaration" do
			expect(func).not_to equal(nil)
			expect(func.kind).to equal(:cursor_function)
		end

		it "has an extent representing the bounds of the function" do
			expect(func.extent).to be_kind_of(SourceRange)
			expect(func.extent.start.line).to equal(5)
			expect(func.extent.end.line).to equal(5)
		end

		it "returns the name of the function" do
			expect(func.spelling).to eq("sum")
			expect(func.display_name).to eq("sum(union List *)")
		end
	end

	describe "Struct Cursors" do
		let (:struct) { find_by_kind(cursor, :cursor_struct) }

		it "can find the first struct" do
			expect(struct).not_to equal(nil)
			expect(struct.kind).to equal(:cursor_struct)
		end

		it "has an extent representing the bounds of the struct" do
			expect(struct.extent.start.line).to equal(1)
			expect(struct.extent.end.line).to equal(4)
		end

		it "returns the name of the struct" do
			expect(struct.spelling).to eq("List")
			expect(struct.display_name).to eq("List")
		end
	end

	describe '#kind_spelling' do
		let (:struct) { find_by_kind(cursor, :cursor_struct) }

		it "returns the spelling of the given kind" do
			expect(struct.kind_spelling).to eq('StructDecl')
		end
	end

	describe '#declaration?' do
		let (:struct) { find_by_kind(cursor, :cursor_struct) }

		it "checks the cursor is declaration" do
			expect(struct.declaration?).to be true
		end
	end

	describe '#reference?' do
		let (:ref) { find_by_kind(cursor, :cursor_type_ref) }

		it "checks the cursor is reference" do
			expect(ref.reference?).to be true
		end
	end

	describe '#expression?' do
		let (:literal) { find_by_kind(cursor, :cursor_integer_literal) }

		it "checks the cursor is expression" do
			expect(literal.expression?).to be true
		end
	end

	describe '#statement?' do
		let (:return_stmt) { find_by_kind(cursor, :cursor_return_stmt) }

		it "checks the cursor is statement" do
			expect(return_stmt.statement?).to be true
		end
	end

	describe '#attribute?' do
		let (:attr) { find_by_kind(cursor_cxx, :cursor_unexposed_attr) }

		it "checks the cursor is attribute" do
			expect(attr.attribute?).to be true
		end
	end

	describe '#public?' do
		let(:public_cursor) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_field_decl and child.spelling == 'public_member_int' } }

		it 'checks access control level is public' do
			expect(public_cursor.public?).to be true
		end
	end

	describe '#private?' do
		let(:private_cursor) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_field_decl and child.spelling == 'private_member_int' } }

		it 'checks access control level is private' do
			expect(private_cursor.private?).to be true
		end
	end

	describe '#protected?' do
		let(:protected_cursor) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_field_decl and child.spelling == 'protected_member_int' } }

		it 'checks access control level is protected' do
			expect(protected_cursor.protected?).to be true
		end
	end

	describe '#preprocessing?' do
		let (:pp) { find_by_kind(cursor_pp, :cursor_macro_definition) }

		it 'checks the cursor is preprocessing' do
			expect(pp.preprocessing?).to be true
		end
	end

	describe '#unexposed?' do
		let(:unexposed_cursor) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_unexposed_expr and child.spelling == 'func_overloaded' } }

		it 'checks the cursor is unexposed' do
			expect(unexposed_cursor.unexposed?).to be true
		end
	end

	describe '#virtual_base?' do
		let(:virtual_base_cursor) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_cxx_base_specifier and parent.spelling == 'B' } }

		it 'checks cursor is virtual base' do
			expect(virtual_base_cursor.virtual_base?).to equal true
		end
	end

	describe '#virtual?' do
		let(:virtual_cursor) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_cxx_method and child.spelling == 'func_a' } }

		it 'checks member function is virtual' do
			expect(virtual_cursor.virtual?).to equal true
		end
	end

	describe '#pure_virtual?' do
		let(:pure_virtual_cursor) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_cxx_method and
				child.spelling == 'func_a' and parent.spelling == 'A' } }

		it 'checks member function is purely virtual' do
			expect(pure_virtual_cursor.pure_virtual?).to equal true
		end
	end

	describe '#static?' do
		let(:static_method_cursor) { find_matching(cursor_cxx) { |child, parent|
			child.kind == :cursor_cxx_method and child.spelling == 'func_b' } }

		it 'checks cursor is static member function' do
			expect(static_method_cursor.static?).to equal true
		end
	end

	describe '#enum_value' do
		let(:enum_value_cursor) { find_matching(cursor_cxx) { |child, parent|
			child.kind == :cursor_enum_constant_decl and child.spelling == 'EnumC' } }

		it 'returns enum value' do
			expect(enum_value_cursor.enum_value).to equal 100
		end
	end

	describe '#enum_unsigned_value' do
		let(:enum_value_cursor) { find_matching(cursor_cxx) { |child, parent|
			child.kind == :cursor_enum_constant_decl and child.spelling == 'EnumC' } }

		it 'returns enum unsigned value' do
			expect(enum_value_cursor.enum_unsigned_value).to eq(100)
		end
	end

	describe '#dynamic_call?' do
		let(:dynamic_call) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_call_expr and child.spelling == 'func_a' and
				child.semantic_parent.spelling == 'f_dynamic_call' } }

		it 'checks if the method call is dynamic' do
			expect(dynamic_call.dynamic_call?).to be true
		end
	end

	describe '#specialized_template' do # looks not working on 3.2
		let(:cursor_function) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_function and child.spelling == 'func_overloaded' } }

		it "returns a cursor that may represent a specialization or instantiation of a template" do
			expect(cursor_function.specialized_template).to be_kind_of(Cursor)
			expect(cursor_function.specialized_template.kind).to be(:cursor_function_template)
		end
	end

	describe '#canonical' do
		let (:structs) { find_all_by_kind(cursor_canon, :cursor_struct) }

		it "mathes 3 cursors" do
			expect(structs.size).to eq(3)
		end

		it "refers the first cursor as canonical one" do
			expect(structs[0].canonical).to eq(structs[0])
			expect(structs[1].canonical).to eq(structs[0])
			expect(structs[2].canonical).to eq(structs[0])
		end
	end

	describe '#definition' do
		let (:structs) { find_all_by_kind(cursor_canon, :cursor_struct) }

		it "mathes 3 cursors" do
			expect(structs.size).to eq(3)
		end

		it "refers the third cursor as definition one" do
			expect(structs[0].definition).to eq(structs[2])
			expect(structs[1].definition).to eq(structs[2])
			expect(structs[2].definition).to eq(structs[2])
		end
	end

	describe '#template_kind' do # looks not working on 3.2
		let(:template) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_function_template and child.spelling == 'func_overloaded' } }

		it "returns the cursor kind of the specializations would be generated" do
			expect(template.template_kind).to be_kind_of(Symbol)
			expect(template.template_kind).to be(:cursor_function)
		end
	end

	describe '#access_specifier' do
		let(:access_specifier_cursor) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_cxx_method and child.spelling == 'func_d' } }

		it 'returns access specifier symbol' do
			expect(access_specifier_cursor.access_specifier).to equal :private
		end
	end

	describe '#language' do
		let(:c_language_cursor) { find_matching(cursor) { |c, p| c.kind == :cursor_struct } }
		let(:cxx_language_cursor) { find_matching(cursor_cxx) { |c, p| c.kind == :cursor_struct } }

		it 'returns :c if the cursor language is C' do
			expect(c_language_cursor.language).to equal :c
		end

		it 'returns :c_plus_plus if the cursor language is C++' do
			expect(cxx_language_cursor.language).to equal :c_plus_plus
		end
	end

	describe '#translation_unit' do
		let (:struct) { find_by_kind(cursor, :cursor_struct) }

		it "can find the first struct" do
			expect(struct).not_to equal(nil)
		end

		it "returns the translation unit that a cursor originated from" do
			expect(struct.translation_unit).to be_kind_of(TranslationUnit)
			expect(struct.translation_unit.spelling).to eq(fixture_path("list.c"))
		end
	end

	describe '#find_references_in_file' do
		let (:struct_cursor) {find_by_kind(cursor_canon, :cursor_struct) }

		it "visits references to the cursor in the main file" do
			counter = 0
			struct_cursor.find_references_in_file do |ref_cursor, ref_src_loc|
				counter += 1
				:continue
			end
			expect(counter).not_to equal(0)
		end

		it "visits references to the cursor in the indicated file" do
			counter = 0
			struct_cursor.find_references_in_file(fixture_path("canonical.c")) do |ref_cursor, ref_src_loc|
				counter += 1
				:continue
			end
			expect(counter).not_to equal(0)
		end
	end

	describe '#linkage' do
		let (:ref) { find_by_kind(cursor, :cursor_type_ref) }
		let (:func) { find_by_kind(cursor, :cursor_function) }

		it "returns :external if the cursor is non-static function" do
			expect(func.linkage).to equal :external
		end

		it "returns :invalid if the cursor does not have linkage" do
			expect(ref.linkage).to equal :invalid
		end
	end

	describe '#exception_specification' do
		let(:exception_yes_1) { find_matching(cursor_cxx) { |child, parent|
			child.kind == :cursor_cxx_method and child.spelling == 'exceptionYes1'
		} }

		it 'can create exceptions 1' do
			expect(exception_yes_1.exception_specification).to be(:none)
		end

		let(:exception_yes_2) { find_matching(cursor_cxx) { |child, parent|
			child.kind == :cursor_cxx_method and child.spelling == 'exceptionYes2'
		} }

		it 'can create exceptions 2' do
			expect(exception_yes_2.exception_specification).to be(:computed_noexcept)
		end

		let(:exception_no_1) { find_matching(cursor_cxx) { |child, parent|
			child.kind == :cursor_cxx_method and child.spelling == 'exceptionNo1'
		} }

		it 'cannot create exceptions 1' do
			expect(exception_no_1.exception_specification).to be(:basic_noexcept)
		end

		let(:exception_no_2) { find_matching(cursor_cxx) { |child, parent|
			child.kind == :cursor_cxx_method and child.spelling == 'exceptionNo2'
		} }

		it 'cannot create exceptions 2' do
			expect(exception_no_2.exception_specification).to be(:computed_noexcept)
		end

		let(:exception_throw) { find_matching(cursor_cxx) { |child, parent|
			child.kind == :cursor_cxx_method and child.spelling == 'exceptionThrow'
		} }

		it 'can create throw exceptions' do
			expect(exception_throw.exception_specification).to be(:dynamic_none)
		end
	end

	describe '#semantic_parent' do
		let(:parent) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_cxx_method and child.spelling == 'func_d' and parent.spelling != 'D' } }

		it 'returns base class as semantic parent' do
			expect(parent.semantic_parent.spelling).to eq('D')
		end
	end

	describe '#lexical_parent' do
		let(:parent) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_cxx_method and child.spelling == 'func_d' and parent.spelling != 'D' } }

		it 'returns translation unit as lexical parent' do
			expect(parent.lexical_parent.kind).to eq(:cursor_translation_unit)
		end
	end

	describe '#included_file' do
		#TODO
	end

	describe '#definition?' do
		let (:struct) { find_all_by_kind(cursor_canon, :cursor_struct).at(2) }

		it "checks cursor is a definition" do
			expect(struct.definition?).to be true
		end
	end

	describe '#usr' do
		let (:func) { find_by_kind(cursor, :cursor_function) }

		it "returns something in string" do
			expect(func.usr).to be_kind_of(String)
		end
	end

	describe '#variadic?' do
		let(:func) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_function and child.spelling == 'f_variadic' } }

		it "checks cursor is a variadic function" do
			expect(func.variadic?).to be true
		end
	end

	describe '#referenced' do
		let(:struct) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_struct and child.spelling == 'A' } }
		let(:ref) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_type_ref and child.spelling == 'struct A' } }

		it "returns a cursor that this cursor references" do
			expect(ref.referenced).to eq(struct)
		end

	end

	describe '#hash' do
		let (:func) { find_by_kind(cursor, :cursor_function) }

		it "computes hash for the cursor" do
			expect(func.hash).to be_kind_of(Integer)
		end
	end

	describe '#availability' do
		let (:func) { find_by_kind(cursor, :cursor_function) }

		it "returns :available for the cursor availability" do
			expect(func.availability).to equal(:available)
		end
	end

	describe '#type' do
		let (:field) { find_by_kind(cursor, :cursor_field_decl) }

		it "returns type for the cursor" do
			expect(field.type).to be_kind_of(Types::Type)
			expect(field.type.kind).to equal(:type_int)
		end
	end

	describe '#underlying_type' do
		let (:typedef) { find_by_kind(cursor_cxx, :cursor_typedef_decl) }

		it "returns type that the cursor type is underlying" do
			expect(typedef.underlying_type).to be_kind_of(Types::Pointer)
			expect(typedef.underlying_type.kind).to equal(:type_pointer)
		end
	end

	describe '#bitfield?' do
		let(:bitfield) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_field_decl and child.spelling == 'bit_field_a' } }
		let(:non_bitfield) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_field_decl and child.spelling == 'non_bit_field_c' } }

		it "returns true if the cursor is bitfield" do
			expect(bitfield.bitfield?).to be true
		end

		it "returns false if the cursor is not bitfield" do
			expect(non_bitfield.bitfield?).to be false
		end
	end

	describe '#bitwidth' do
		let(:bitfield) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_field_decl and child.spelling == 'bit_field_a' } }
		let(:non_bitfield) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_field_decl and child.spelling == 'non_bit_field_c' } }

		it "returns the bit width of the bit field if the cursor is bitfield" do
			expect(bitfield.bitwidth).to be_kind_of(Integer)
			expect(bitfield.bitwidth).to eq(2)
		end

		it "returns -1 if the cursor is not bitfield" do
			expect(non_bitfield.bitwidth).to eq(-1)
		end
	end

	describe '#enum_type' do
		let(:enum) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_enum_decl and child.spelling == 'normal_enum' } }

		it "returns the integer type of the enum declaration" do
			expect(enum.enum_type).to be_kind_of(Types::Type)
			expect(enum.enum_type.kind).to be(:type_uint)
		end
	end

	describe '#platform_availability' do
		let(:func) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_function and child.spelling == 'availability_func'} }
		let(:availability) { func.platform_availability }

		it "returns the availability of the entity as Hash" do
			expect(availability).to be_kind_of(Hash)
			expect(availability[:always_deprecated]).to be_kind_of(Integer)
			expect(availability[:always_unavailable]).to be_kind_of(Integer)
			expect(availability[:deprecated_message]).to be_kind_of(String)
			expect(availability[:unavailable_message]).to be_kind_of(String)
			expect(availability[:availability]).to be_kind_of(Array)
		end
	end

	describe '#overriddens' do
		let(:override_cursor) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_cxx_method and
				child.spelling == 'func_a' and parent.spelling == 'D' } }

		it "returns the set of methods which are overridden by this cursor method" do
			expect(override_cursor.overriddens).to be_kind_of(Array)
			expect(override_cursor.overriddens.size).to eq(2)
			expect(override_cursor.overriddens.map{|cur| cur.semantic_parent.spelling}).to eq(["B", "C"])
		end
	end

	describe '#overloaded_decl' do
		let(:overloaded) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_overloaded_decl_ref and child.spelling == 'func_overloaded' } }

		it "returns a cursor for one of the overloaded declarations" do
			expect(overloaded.overloaded_decl(0)).to be_kind_of(Cursor)
			expect(overloaded.overloaded_decl(0).kind).to be(:cursor_function_template)
			expect(overloaded.overloaded_decl(0).spelling).to eq('func_overloaded')
		end
	end

	describe '#num_overloaded_decls' do
		let(:overloaded) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_overloaded_decl_ref and child.spelling == 'func_overloaded' } }

		it "returns the number of overloaded declarations" do
			expect(overloaded.num_overloaded_decls).to be_kind_of(Integer)
			expect(overloaded.num_overloaded_decls).to be(2)
		end
	end

	describe '#qualified_name' do
		let(:qualified) { find_matching(cursor_cxx) { |child, parent|
			child.kind == :cursor_struct and child.spelling == 'B' } }
		let(:base_class)  { find_matching(qualified) { |child, parent|
			child.kind == :cursor_cxx_base_specifier } }

		it "returns a qualified name for struct" do
			expect(qualified.qualified_name).to eq("B")
		end

		it "throws error for base class qualified name" do
			expect{base_class.qualified_name}.to raise_error(ArgumentError)
		end
	end

	describe '#objc_type_encoding' do
		#TODO
	end

	describe '#argument' do
		let(:func) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_function and child.spelling == 'f_non_variadic' } }

		it "returns the argument cursor of the function" do
			expect(func.argument(0)).to be_kind_of(Cursor)
			expect(func.argument(0).spelling).to eq('a')
		end
	end

	describe '#num_arguments' do
			let(:cursor_cxx) { Index.new.parse_translation_unit(fixture_path("test.cxx")).cursor }
		let(:func) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_function and child.spelling == 'f_non_variadic' } }

		it "returns the number of non-variadic arguments" do
			expect(func.num_arguments).to be_kind_of(Integer)
			expect(func.num_arguments).to be(3)
		end
	end

	describe '#result_type' do
		let(:func) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_function and child.spelling == 'f_non_variadic' } }

		it "result the result type of the function" do
			expect(func.result_type).to be_kind_of(Types::Type)
			expect(func.result_type.kind).to be(:type_void)
		end
	end

	describe '#raw_comment_text' do
		let(:func) { find_matching(cursor_pp) { |child, parent|
				child.kind == :cursor_function and child.spelling == 'a_function' } }

		it "checks the cursor is declaration" do
			expect(func.raw_comment_text).to be_kind_of(String)
			expect(func.raw_comment_text).not_to be_empty
		end
	end

	describe '#comment' do
		let(:func) { find_matching(cursor_pp) { |child, parent|
				child.kind == :cursor_function and child.spelling == 'a_function' } }

		it "checks the cursor is declaration" do
			expect(func.comment).to be_kind_of(Comment)
		end
	end

	describe '#included_file' do
		let (:inclusion) { find_by_kind(cursor_pp, :cursor_inclusion_directive) }

		it 'returns the file that is included by the given inclusion directive cursor' do
			expect(inclusion.included_file).to be_kind_of(FFI::Clang::File)
			expect(File.basename(inclusion.included_file.name)).to eq("docs.h")
		end
	end

	describe '#references' do
		let (:struct_cursor) { find_by_kind(cursor_canon, :cursor_struct) }
		let (:unspecified_references) { struct_cursor.references }
		let (:specified_references) { struct_cursor.references(fixture_path("canonical.c")) }

		it "returns an Array of reference Cursors in the main file" do
			expect(unspecified_references).to be_kind_of(Array)
			expect(unspecified_references.length).not_to equal(0)
			expect(unspecified_references).to all(be_a (FFI::Clang::Cursor))
		end

		it "returns an Array of reference Cursors in the specified file" do
			expect(specified_references).to be_kind_of(Array)
			expect(specified_references.length).not_to equal(0)
			expect(specified_references).to all(be_a (FFI::Clang::Cursor))
		end
	end

	describe Cursor::PlatformAvailability do
		let(:func) { find_matching(cursor_cxx) { |child, parent|
				child.kind == :cursor_function and child.spelling == 'availability_func'} }
		let(:availability) { func.platform_availability[:availability].first }

		it "can be obtained by Cursor#platform_availability" do
			expect(availability).to be_kind_of(Cursor::PlatformAvailability)
		end

		describe "#platform" do
			it "returns availability information for the platform" do
				expect(availability.platform).to be_kind_of(String)
			end
		end

		describe "#introduced" do
			it "returns the version number in which this entity was introduced" do
				expect(availability.introduced).to be_kind_of(Lib::CXVersion)
				expect(availability.introduced.to_s).to eq("10.4.1")
			end
		end

		describe "#deprecated" do
			it "returns the version number in which this entity was deprecated" do
				expect(availability.deprecated).to be_kind_of(Lib::CXVersion)
				expect(availability.deprecated.to_s).to eq("10.6")
			end
		end

		describe "#obsoleted" do
			it "returns the version number in which this entity was obsoleted" do
				expect(availability.obsoleted).to be_kind_of(Lib::CXVersion)
				expect(availability.obsoleted.to_s).to eq("10.7")
			end
		end

		describe "#unavailable" do
			it "returns whether the entity is unavailable on this platform" do
				expect(availability.unavailable).to be false
			end
		end

		describe "#message" do
			it "returns an optional message to provide to a user of this API" do
				expect(availability.message).to be_kind_of(String)
			end
		end
	end

	describe '#forward' do
		let(:opaque) { find_matching(cursor_forward) { |child, parent|
			child.kind == :cursor_struct and child.spelling == 'Opaque' } }
		let(:forward) { find_matching(cursor_forward) { |child, parent|
			child.kind == :cursor_struct and child.spelling == 'Forward' } }

		describe '#opaque' do
			it "is an opaque declaration" do
				expect(opaque.opaque_declaration?).to eq(true)
				expect(opaque.forward_declaration?).to eq(false)
			end 
		end

		describe '#forward' do
			it "is a forward declaration" do
				expect(forward.opaque_declaration?).to eq(false)
				expect(forward.forward_declaration?).to eq(true)
			end
		end
	end

	describe '#anonymous' do
		let(:struct) { find_matching(cursor_anonymous) { |child, parent|
			child.kind == :cursor_struct	} }

		it "is an an anonymous structure" do
			expect(struct.anonymous?).to eq(true)
		end
	end
end
