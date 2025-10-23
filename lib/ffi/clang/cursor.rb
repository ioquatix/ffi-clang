# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2013, by Garry Marshall.
# Copyright, 2013-2025, by Samuel Williams.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2013, by Dave Wilkinson.
# Copyright, 2013, by Takeshi Watanabe.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2014, by George Pimm.
# Copyright, 2014, by Niklas Therning.
# Copyright, 2019, by Michael Metivier.
# Copyright, 2022, by Motonori Iwamuro.
# Copyright, 2023-2025, by Charlie Savage.

require_relative "lib/cursor"
require_relative "lib/code_completion"

require_relative "printing_policy"
require_relative "source_location"
require_relative "source_range"
require_relative "comment"

module FFI
	module Clang
		# Represents a cursor in the abstract syntax tree (AST).
		class Cursor
			include Enumerable
			
			# @attribute [FFI::Lib::CXCursor] The underlying libclang cursor structure.
			attr_reader :cursor
			
			# @attribute [TranslationUnit] The translation unit this cursor belongs to.
			attr_reader :translation_unit
			
			# Get a null cursor.
			# @returns [Cursor] A null cursor instance.
			def self.null_cursor
				Cursor.new Lib.get_null_cursor, nil
			end
			
			# Get the spelling of a cursor kind.
			# @parameter kind [Symbol] The cursor kind.
			# @returns [String] The string representation of the cursor kind.
			def self.kind_spelling(kind)
				Lib.extract_string Lib.get_cursor_kind_spelling(kind)
			end
			
			# Initialize a cursor with a libclang cursor structure.
			# @parameter cxcursor [Lib::CXCursor] The libclang cursor.
			# @parameter translation_unit [TranslationUnit] The parent translation unit.
			def initialize(cxcursor, translation_unit)
				@cursor = cxcursor
				@translation_unit = translation_unit
			end
			
			# Check if this cursor is null.
			# @returns [Boolean] True if the cursor is null.
			def null?
				Lib.cursor_is_null(@cursor) != 0
			end
			
			# Get the raw comment text associated with this cursor.
			# @returns [String] The raw comment text.
			def raw_comment_text
				Lib.extract_string Lib.cursor_get_raw_comment_text(@cursor)
			end
			
			# Get the parsed comment associated with this cursor.
			# @returns [Comment] The parsed comment structure.
			def comment
				Comment.build_from Lib.cursor_get_parsed_comment(@cursor)
			end
			
			# Get the source range of the comment.
			# @returns [SourceRange] The comment source range.
			def comment_range
				SourceRange.new(Lib.cursor_get_comment_range(@cursor))
			end
			
			# Get the code completion string for this cursor.
			# @returns [CodeCompletion::String] The completion string.
			def completion
				CodeCompletion::String.new Lib.get_cursor_completion_string(@cursor)
			end
			
			# Check if this cursor is anonymous.
			# @returns [Boolean] True if the cursor is anonymous.
			def anonymous?
				Lib.cursor_is_anonymous(@cursor) != 0
			end
			
			# Check if this cursor is an anonymous record declaration.
			# @returns [Boolean] True if it's an anonymous record declaration.
			def anonymous_record_declaration?
				Lib.cursor_is_anonymous_record_decl(@cursor) != 0
			end
			
			# Check if this cursor is a declaration.
			# @returns [Boolean] True if it's a declaration.
			def declaration?
				Lib.is_declaration(kind) != 0
			end
			
			# Check if this cursor is a reference.
			# @returns [Boolean] True if it's a reference.
			def reference?
				Lib.is_reference(kind) != 0
			end
			
			# Check if this cursor is an expression.
			# @returns [Boolean] True if it's an expression.
			def expression?
				Lib.is_expression(kind) != 0
			end
			
			# Check if this cursor is a statement.
			# @returns [Boolean] True if it's a statement.
			def statement?
				Lib.is_statement(kind) != 0
			end
			
			# Check if this cursor is an attribute.
			# @returns [Boolean] True if it's an attribute.
			def attribute?
				Lib.is_attribute(kind) != 0
			end
			
			# Check if this cursor has public access.
			# @returns [Boolean] True if the cursor is public.
			def public?
				Lib.cxx_get_access_specifier(@cursor) == :public
			end
			
			# Check if this cursor has private access.
			# @returns [Boolean] True if the cursor is private.
			def private?
				Lib.cxx_get_access_specifier(@cursor) == :private
			end
			
			# Check if this cursor has protected access.
			# @returns [Boolean] True if the cursor is protected.
			def protected?
				Lib.cxx_get_access_specifier(@cursor) == :protected
			end
			
			# Check if this cursor is invalid.
			# @returns [Boolean] True if the cursor is invalid.
			def invalid?
				Lib.is_invalid(kind) != 0
			end
			
			# Check if this cursor is a translation unit.
			# @returns [Boolean] True if it's a translation unit.
			def translation_unit?
				Lib.is_translation_unit(kind) != 0
			end
			
			# Check if this cursor is a preprocessing directive.
			# @returns [Boolean] True if it's a preprocessing directive.
			def preprocessing?
				Lib.is_preprocessing(kind) != 0
			end
			
			# Check if this cursor is unexposed.
			# @returns [Boolean] True if the cursor is unexposed.
			def unexposed?
				Lib.is_unexposed(kind) != 0
			end
			
			# Get the expansion location of this cursor.
			# @returns [ExpansionLocation] The expansion location.
			def expansion_location
				ExpansionLocation.new(Lib.get_cursor_location(@cursor))
			end
			alias :location :expansion_location
			
			# Get the presumed location of this cursor.
			# @returns [PresumedLocation] The presumed location.
			def presumed_location
				PresumedLocation.new(Lib.get_cursor_location(@cursor))
			end
			
			# Get the spelling location of this cursor.
			# @returns [SpellingLocation] The spelling location.
			def spelling_location
				SpellingLocation.new(Lib.get_cursor_location(@cursor))
			end
			
			# Get the file location of this cursor.
			# @returns [FileLocation] The file location.
			def file_location
				FileLocation.new(Lib.get_cursor_location(@cursor))
			end
			
			# Get the source extent of this cursor.
			# @returns [SourceRange] The source extent.
			def extent
				SourceRange.new(Lib.get_cursor_extent(@cursor))
			end
			
			# Get the display name of this cursor.
			# @returns [String] The display name.
			def display_name
				Lib.extract_string Lib.get_cursor_display_name(@cursor)
			end
			
			# Get the qualified display name including parent scope.
			# @returns [String | Nil] The qualified display name, or `nil` for translation units.
			# @raises [ArgumentError] If the semantic parent is invalid.
			def qualified_display_name
				if self.kind != :cursor_translation_unit
					if self.semantic_parent.kind == :cursor_invalid_file
						raise(ArgumentError, "Invalid semantic parent: #{self}")
					end
					result = self.semantic_parent.qualified_display_name
					result ? "#{result}::#{self.display_name}" : self.display_name
				end
			end
			
			# Get the fully qualified name of this cursor.
			# @returns [String | Nil] The qualified name, or `nil` for translation units.
			# @raises [ArgumentError] If the semantic parent is invalid.
			def qualified_name
				if self.kind != :cursor_translation_unit
					if self.semantic_parent.kind == :cursor_invalid_file
						raise(ArgumentError, "Invalid semantic parent: #{self}")
					end
					result = self.semantic_parent.qualified_name
					result ? "#{result}::#{self.spelling}" : self.spelling
				end
			end
			
			# Get the spelling (name) of this cursor.
			# @returns [String] The cursor spelling.
			def spelling
				Lib.extract_string Lib.get_cursor_spelling(@cursor)
			end
			
			# Get the printing policy for this cursor.
			# @returns [PrintingPolicy] The printing policy.
			def printing_policy
				PrintingPolicy.new(cursor)
			end
			
			# Get the Unified Symbol Resolution (USR) for this cursor.
			# @returns [String] The USR string.
			def usr
				Lib.extract_string Lib.get_cursor_usr(@cursor)
			end
			
			# Get the kind of this cursor.
			# @returns [Symbol | Nil] The cursor kind.
			def kind
				@cursor ? @cursor[:kind] : nil
			end
			
			# Get the spelling of the cursor kind.
			# @returns [String] The cursor kind spelling.
			def kind_spelling
				Cursor.kind_spelling @cursor[:kind]
			end
			
			# Get the type of this cursor.
			# @returns [Types::Type] The cursor type.
			def type
				Types::Type.create Lib.get_cursor_type(@cursor), @translation_unit
			end
			
			# Get the result type for a function cursor.
			# @returns [Types::Type] The result type.
			def result_type
				Types::Type.create Lib.get_cursor_result_type(@cursor), @translation_unit
			end
			
			# Get the underlying type for a typedef cursor.
			# @returns [Types::Type] The underlying type.
			def underlying_type
				Types::Type.create Lib.get_typedef_decl_underlying_type(@cursor), @translation_unit
			end
			
			# Check if this cursor is a virtual base class.
			# @returns [Boolean] True if it's a virtual base.
			def virtual_base?
				Lib.is_virtual_base(@cursor) != 0
			end
			
			# Check if this cursor is a dynamic call.
			# @returns [Boolean] True if it's a dynamic call.
			def dynamic_call?
				Lib.is_dynamic_call(@cursor) != 0
			end
			
			# Check if this cursor is variadic.
			# @returns [Boolean] True if the cursor is variadic.
			def variadic?
				Lib.is_variadic(@cursor) != 0
			end
			
			# Check if this cursor is a definition.
			# @returns [Boolean] True if the cursor is a definition.
			def definition?
				Lib.is_definition(@cursor) != 0
			end
			
			# Check if this is a static method.
			# @returns [Boolean] True if the method is static.
			def static?
				Lib.cxx_method_is_static(@cursor) != 0
			end
			
			# Check if this is a virtual method.
			# @returns [Boolean] True if the method is virtual.
			def virtual?
				Lib.cxx_method_is_virtual(@cursor) != 0
			end
			
			# Check if this is a pure virtual method.
			# @returns [Boolean] True if the method is pure virtual.
			def pure_virtual?
				Lib.cxx_method_is_pure_virtual(@cursor) != 0
			end
			
			# Get the value of an enum constant.
			# @returns [Integer] The enum value.
			def enum_value
				Lib.get_enum_value @cursor
			end
			
			# Get the unsigned value of an enum constant.
			# @returns [Integer] The unsigned enum value.
			def enum_unsigned_value
				Lib.get_enum_unsigned_value @cursor
			end
			
			# Get the integer type of an enum declaration.
			# @returns [Types::Type] The enum's underlying integer type.
			def enum_type
				Types::Type.create Lib.get_enum_decl_integer_type(@cursor), @translation_unit
			end
			
			# Get the template that this cursor specializes.
			# @returns [Cursor] The specialized template cursor.
			def specialized_template
				Cursor.new Lib.get_specialized_cursor_template(@cursor), @translation_unit
			end
			
			# Get the canonical cursor for this cursor.
			# @returns [Cursor] The canonical cursor.
			def canonical
				Cursor.new Lib.get_canonical_cursor(@cursor), @translation_unit
			end
			
			# Get the definition cursor for this cursor.
			# @returns [Cursor] The definition cursor.
			def definition
				Cursor.new Lib.get_cursor_definition(@cursor), @translation_unit
			end
			
			# Check if this is an opaque declaration without a definition.
			# @returns [Boolean] True if it's an opaque declaration.
			def opaque_declaration?
				# Is this a declaration that does not have a definition in the translation unit
				self.declaration? && !self.definition? && self.definition.invalid?
			end
			
			# Check if this is a forward declaration.
			# @returns [Boolean] True if it's a forward declaration.
			def forward_declaration?
				# Is this a forward declaration for a definition contained in the same translation_unit?
				# https://joshpeterson.github.io/identifying-a-forward-declaration-with-libclang
				#
				# Possible alternate implementations?
				# self.declaration? && !self.definition? && self.definition
				# !self.definition? && self.definition
				self.declaration? && !self.eql?(self.definition) && !self.definition.invalid?
			end
			
			# Get the cursor referenced by this cursor.
			# @returns [Cursor] The referenced cursor.
			def referenced
				Cursor.new Lib.get_cursor_referenced(@cursor), @translation_unit
			end
			
			# Get the semantic parent of this cursor.
			# @returns [Cursor] The semantic parent cursor.
			def semantic_parent
				Cursor.new Lib.get_cursor_semantic_parent(@cursor), @translation_unit
			end
			
			# Get the lexical parent of this cursor.
			# @returns [Cursor] The lexical parent cursor.
			def lexical_parent
				Cursor.new Lib.get_cursor_lexical_parent(@cursor), @translation_unit
			end
			
			# Get the template cursor kind.
			# @returns [Symbol] The template cursor kind.
			def template_kind
				Lib.get_template_cursor_kind @cursor
			end
			
			# Get the C++ access specifier.
			# @returns [Symbol] The access specifier (`:public`, `:private`, or `:protected`).
			def access_specifier
				Lib.get_cxx_access_specifier @cursor
			end
			
			# Get the programming language of this cursor.
			# @returns [Symbol] The language symbol.
			def language
				Lib.get_language @cursor
			end
			
			# Get the number of arguments for this cursor.
			# @returns [Integer] The number of arguments.
			def num_args
				Lib.get_num_args @cursor
			end
			
			# Iterate over child cursors.
			# @parameter recurse [Boolean] Whether to recurse into children by default.
			# @yields {|cursor, parent| ...} Each child cursor with its parent.
			# 	@parameter cursor [Cursor] The child cursor.
			# 	@parameter parent [Cursor] The parent cursor.
			# @returns [Enumerator] If no block is given.
			def each(recurse = true, &block)
				return to_enum(:each, recurse) unless block_given?
				
				adapter = Proc.new do |cxcursor, parent_cursor, unused|
					# Call the block and capture the result. This lets advanced users
					# modify the recursion on a case by case basis if needed
					result = block.call Cursor.new(cxcursor, @translation_unit), Cursor.new(parent_cursor, @translation_unit)
					case result
					when :continue
						:continue
					when :recurse
						:recurse
					else
						recurse ? :recurse : :continue
					end
				end
				
				Lib.visit_children(@cursor, adapter, nil)
			end
			
			# Visit only direct children without recursing.
			# @yields {|cursor, parent| ...} Each direct child cursor.
			# 	@parameter cursor [Cursor] The child cursor.
			# 	@parameter parent [Cursor] The parent cursor.
			def visit_children(&block)
				each(false, &block)
			end
			
			# Find ancestors of this cursor by kind.
			# @parameter kinds [Array(Symbol)] The cursor kinds to search for.
			# @returns [Array(Cursor)] Array of ancestor cursors matching the kinds.
			def ancestors_by_kind(*kinds)
				result = Array.new
				
				parent = self
				while parent != self.semantic_parent
					parent = self.semantic_parent
					if kinds.include?(parent.kind)
						result << parent
					end
				end
				result
			end
			
			# Find child cursors by kind.
			# @parameter recurse [Boolean | Nil] Whether to recurse into children.
			# @parameter kinds [Array(Symbol)] The cursor kinds to search for.
			# @returns [Array(Cursor)] Array of matching cursors.
			# @raises [RuntimeError] If recurse parameter is not nil or boolean.
			def find_by_kind(recurse, *kinds)
				unless (recurse == nil || recurse == true || recurse == false)
					raise("Recurse parameter must be nil or a boolean value. Value was: #{recurse}")
				end
				
				result = Array.new
				self.each(recurse) do |child, parent|
					if kinds.include?(child.kind)
						result << child
					end
				end
				result
			end
			
			# Find all references to this cursor in a file.
			# @parameter file [String | Nil] The file path, or `nil` to use the translation unit file.
			# @yields {|cursor, range| ...} Each reference with its cursor and source range.
			# 	@parameter cursor [Cursor] The reference cursor.
			# 	@parameter range [SourceRange] The source range of the reference.
			def find_references_in_file(file = nil, &block)
				file ||= Lib.extract_string Lib.get_translation_unit_spelling(@translation_unit)
				
				visit_adapter = Proc.new do |unused, cxcursor, cxsource_range|
					block.call Cursor.new(cxcursor, @translation_unit), SourceRange.new(cxsource_range)
				end
				visitor = FFI::Clang::Lib::CXCursorAndRangeVisitor.new
				visitor[:visit] = visit_adapter
				
				Lib.find_references_in_file(@cursor, Lib.get_file(@translation_unit, file), visitor)
			end
			
			# Get the linkage of this cursor.
			# @returns [Symbol] The linkage kind.
			def linkage
				Lib.get_cursor_linkage(@cursor)
			end
			
			# Get the exception specification type for this cursor.
			# @returns [Symbol] The exception specification type.
			def exception_specification
				Lib.get_cursor_exception_specification_type(@cursor)
			end
			
			# Get the availability of this cursor.
			# @returns [Symbol] The availability status.
			def availability
				Lib.get_cursor_availability(@cursor)
			end
			
			# Get the file included by this cursor.
			# @returns [File] The included file.
			def included_file
				File.new Lib.get_included_file(@cursor), @translation_unit
			end
			
			# Get platform availability information for this cursor.
			# @parameter max_availability_size [Integer] Maximum number of platforms to query.
			# @returns [Hash] Platform availability information.
			def platform_availability(max_availability_size = 4)
				availability_ptr = FFI::MemoryPointer.new(Lib::CXPlatformAvailability, max_availability_size)
				always_deprecated_ptr = FFI::MemoryPointer.new :int
				always_unavailable_ptr = FFI::MemoryPointer.new :int
				deprecated_message_ptr = FFI::MemoryPointer.new Lib::CXString
				unavailable_message_ptr = FFI::MemoryPointer.new Lib::CXString
				
				actual_availability_size = Lib.get_cursor_platform_availability(
					@cursor,
					always_deprecated_ptr, deprecated_message_ptr,
					always_unavailable_ptr, unavailable_message_ptr,
					availability_ptr, max_availability_size)
				
				availability = []
				cur_ptr = availability_ptr
				[actual_availability_size, max_availability_size].min.times {availability << PlatformAvailability.new(cur_ptr)
																																																																	cur_ptr += Lib::CXPlatformAvailability.size
				}
				
				# return as Hash
				{
					always_deprecated: always_deprecated_ptr.get_int(0),
					always_unavailable: always_unavailable_ptr.get_int(0),
					deprecated_message: Lib.extract_string(Lib::CXString.new(deprecated_message_ptr)),
					unavailable_message: Lib.extract_string(Lib::CXString.new(unavailable_message_ptr)),
					availability: availability
				}
			end
			
			# Get all cursors that this cursor overrides.
			# @returns [Array(Cursor)] Array of overridden cursors.
			def overriddens
				cursor_ptr = FFI::MemoryPointer.new :pointer
				num_ptr = FFI::MemoryPointer.new :uint
				Lib.get_overridden_cursors(@cursor, cursor_ptr, num_ptr)
				num = num_ptr.get_uint(0)
				cur_ptr = cursor_ptr.get_pointer(0)
				
				overriddens = []
				num.times {overriddens << Cursor.new(cur_ptr, @translation_unit)
															cur_ptr += Lib::CXCursor.size
				}
				Lib.dispose_overridden_cursors(cursor_ptr.get_pointer(0)) if num != 0
				overriddens
			end
			
			# Check if this cursor represents a bitfield.
			# @returns [Boolean] True if it's a bitfield.
			def bitfield?
				Lib.is_bit_field(@cursor) != 0
			end
			
			# Get the bit width of a bitfield.
			# @returns [Integer] The bitfield width.
			def bitwidth
				Lib.get_field_decl_bit_width(@cursor)
			end
			
			# Get an overloaded declaration by index.
			# @parameter i [Integer] The index of the overloaded declaration.
			# @returns [Cursor] The overloaded declaration cursor.
			def overloaded_decl(i)
				Cursor.new Lib.get_overloaded_decl(@cursor, i), @translation_unit
			end
			
			# Get the number of overloaded declarations.
			# @returns [Integer] The number of overloaded declarations.
			def num_overloaded_decls
				Lib.get_num_overloaded_decls(@cursor)
			end
			
			# Get the Objective-C type encoding.
			# @returns [String] The Objective-C type encoding.
			def objc_type_encoding
				Lib.extract_string Lib.get_decl_objc_type_encoding(@cursor)
			end
			
			# Get a function or method argument by index.
			# @parameter i [Integer] The argument index.
			# @returns [Cursor] The argument cursor.
			def argument(i)
				Cursor.new Lib.cursor_get_argument(@cursor, i), @translation_unit
			end
			
			# Get the number of arguments.
			# @returns [Integer] The number of arguments.
			def num_arguments
				Lib.cursor_get_num_arguments(@cursor)
			end
			
			# Check if this cursor equals another cursor.
			# @parameter other [Cursor] The cursor to compare with.
			# @returns [Boolean] True if the cursors are equal.
			def eql?(other)
				Lib.are_equal(@cursor, other.cursor) != 0
			end
			alias == eql?
			
			# Get the hash code for this cursor.
			# @returns [Integer] The hash code.
			def hash
				Lib.get_cursor_hash(@cursor)
			end
			
			# Get a string representation of this cursor.
			# @returns [String] The cursor string representation.
			def to_s
				"Cursor <#{self.kind.to_s.gsub(/^cursor_/, '')}: #{self.spelling}>"
			end
			
			# Find all references to this cursor.
			# @parameter file [String | Nil] The file to search in, or `nil` for the translation unit file.
			# @returns [Array(Cursor)] Array of reference cursors.
			def references(file = nil)
				refs = []
				self.find_references_in_file(file) do |cursor, unused|
					refs << cursor
					:continue
				end
				refs
			end
			
			# Check if this is a converting constructor.
			# @returns [Boolean] True if it's a converting constructor.
			def converting_constructor?
				Lib.is_converting_constructor(@cursor) != 0
			end
			
			# Check if this is a copy constructor.
			# @returns [Boolean] True if it's a copy constructor.
			def copy_constructor?
				Lib.is_copy_constructor(@cursor) != 0
			end
			
			# Check if this is a default constructor.
			# @returns [Boolean] True if it's a default constructor.
			def default_constructor?
				Lib.is_default_constructor(@cursor) != 0
			end
			
			# Check if this is a move constructor.
			# @returns [Boolean] True if it's a move constructor.
			def move_constructor?
				Lib.is_move_constructor(@cursor) != 0
			end
			
			# Check if this cursor is mutable.
			# @returns [Boolean] True if it's mutable.
			def mutable?
				Lib.is_mutable(@cursor) != 0
			end
			
			# Check if this cursor is defaulted.
			# @returns [Boolean] True if it's defaulted.
			def defaulted?
				Lib.is_defaulted(@cursor) != 0
			end
			
			# Check if this cursor is deleted.
			# @returns [Boolean] True if it's deleted.
			def deleted?
				Lib.is_deleted(@cursor) != 0
			end
			
			# Check if this is a copy assignment operator.
			# @returns [Boolean] True if it's a copy assignment operator.
			def copy_assignment_operator?
				Lib.is_copy_assignment_operator(@cursor) != 0
			end
			
			# Check if this is a move assignment operator.
			# @returns [Boolean] True if it's a move assignment operator.
			def move_assignment_operator?
				Lib.is_move_assignment_operator(@cursor) != 0
			end
			
			# Check if this cursor is explicit.
			# @returns [Boolean] True if it's explicit.
			def explicit?
				Lib.is_explicit(@cursor) != 0
			end
			
			# Check if this cursor is abstract.
			# @returns [Boolean] True if it's abstract.
			def abstract?
				Lib.is_abstract(@cursor) != 0
			end
			
			# Check if this is a scoped enum.
			# @returns [Boolean] True if it's a scoped enum.
			def enum_scoped?
				Lib.is_enum_scoped(@cursor) != 0
			end
			
			# Check if this cursor is const-qualified.
			# @returns [Boolean] True if it's const.
			def const?
				Lib.is_const(@cursor) != 0
			end
			
			# Represents platform availability information for a cursor.
			class PlatformAvailability < AutoPointer
				# Initialize platform availability from a memory pointer.
				# @parameter memory_pointer [FFI::MemoryPointer] The memory pointer.
				def initialize(memory_pointer)
					pointer = FFI::Pointer.new(memory_pointer)
					super(pointer)
					
					# I'm not sure this is safe.
					# Keep a reference to CXPlatformAvailability itself allocated by MemoryPointer.
					@memory_pointer = memory_pointer
					@platform_availability = Lib::CXPlatformAvailability.new(memory_pointer)
				end
				
				# Release the platform availability pointer.
				# @parameter pointer [FFI::Pointer] The pointer to release.
				def self.release(pointer)
					# Memory allocated by get_cursor_platform_availability is managed by AutoPointer.
					Lib.dispose_platform_availability(Lib::CXPlatformAvailability.new(pointer))
				end
				
				# Get the platform name.
				# @returns [String] The platform name.
				def platform
					Lib.get_string @platform_availability[:platform]
				end
				
				# Get the platform name.
				# @returns [String] The platform name.
				def platform
					Lib.get_string @platform_availability[:platform]
				end
				
				# Get the version where the feature was introduced.
				# @returns [Lib::CXVersion] The introduced version.
				def introduced
					@platform_availability[:introduced]
				end
				
				# Get the version where the feature was deprecated.
				# @returns [Lib::CXVersion] The deprecated version.
				def deprecated
					@platform_availability[:deprecated]
				end
				
				# Get the version where the feature was obsoleted.
				# @returns [Lib::CXVersion] The obsoleted version.
				def obsoleted
					@platform_availability[:obsoleted]
				end
				
				# Check if the feature is unavailable.
				# @returns [Boolean] True if unavailable.
				def unavailable
					@platform_availability[:unavailable] != 0
				end
				
				# Get the availability message.
				# @returns [String] The availability message.
				def message
					Lib.get_string @platform_availability[:message]
				end
			end
		end
	end
end
