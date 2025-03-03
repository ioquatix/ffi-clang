# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2013, by Garry Marshall.
# Copyright, 2013-2024, by Samuel Williams.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2013, by Dave Wilkinson.
# Copyright, 2013, by Takeshi Watanabe.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2014, by George Pimm.
# Copyright, 2014, by Niklas Therning.
# Copyright, 2019, by Michael Metivier.
# Copyright, 2022, by Motonori Iwamuro.
# Copyright, 2023-2024, by Charlie Savage.

require_relative 'lib/cursor'
require_relative 'lib/code_completion'

require_relative 'printing_policy'
require_relative 'source_location'
require_relative 'source_range'
require_relative 'comment'

module FFI
	module Clang
		class Cursor
			include Enumerable

			attr_reader :cursor
			attr_reader :translation_unit

			def self.null_cursor
				Cursor.new Lib.get_null_cursor, nil
			end

			# this function is categorized as "Debugging facilities"
			def self.kind_spelling(kind)
				Lib.extract_string Lib.get_cursor_kind_spelling(kind)
			end

			def initialize(cxcursor, translation_unit)
				@cursor = cxcursor
				@translation_unit = translation_unit
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

			def comment_range
				SourceRange.new(Lib.cursor_get_comment_range(@cursor))
			end

			def completion
				CodeCompletion::String.new Lib.get_cursor_completion_string(@cursor)
			end

			def anonymous?
				Lib.cursor_is_anonymous(@cursor) != 0
			end

			def anonymous_record_declaration?
				Lib.cursor_is_anonymous_record_decl(@cursor) != 0
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

			def public?
				Lib.cxx_get_access_specifier(@cursor) == :public
			end

			def private?
				Lib.cxx_get_access_specifier(@cursor) == :private
			end

			def protected?
				Lib.cxx_get_access_specifier(@cursor) == :protected
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

			def expansion_location
				ExpansionLocation.new(Lib.get_cursor_location(@cursor))
			end
			alias :location :expansion_location

			def presumed_location
				PresumedLocation.new(Lib.get_cursor_location(@cursor))
			end

			def spelling_location
				SpellingLocation.new(Lib.get_cursor_location(@cursor))
			end

			def file_location
				FileLocation.new(Lib.get_cursor_location(@cursor))
			end

			def extent
				SourceRange.new(Lib.get_cursor_extent(@cursor))
			end

			def display_name
				Lib.extract_string Lib.get_cursor_display_name(@cursor)
			end

			def qualified_display_name
				if self.kind != :cursor_translation_unit
					if self.semantic_parent.kind == :cursor_invalid_file
						raise(ArgumentError, "Invalid semantic parent: #{self}")
					end
					result = self.semantic_parent.qualified_name
					result ? "#{result}::#{self.display_name}" : self.spelling
				end
			end

			def qualified_name
				if self.kind != :cursor_translation_unit
					if self.semantic_parent.kind == :cursor_invalid_file
						raise(ArgumentError, "Invalid semantic parent: #{self}")
					end
					result = self.semantic_parent.qualified_name
					result ? "#{result}::#{self.spelling}" : self.spelling
				end
			end

			def spelling
				Lib.extract_string Lib.get_cursor_spelling(@cursor)
			end

			def printing_policy
				PrintingPolicy.new(cursor)
			end

			def usr
				Lib.extract_string Lib.get_cursor_usr(@cursor)
			end

			def kind
				@cursor ? @cursor[:kind] : nil
			end

			def kind_spelling
				Cursor.kind_spelling @cursor[:kind]
			end

			def type
				Types::Type.create Lib.get_cursor_type(@cursor), @translation_unit
			end

			def result_type
				Types::Type.create Lib.get_cursor_result_type(@cursor), @translation_unit
			end

			def underlying_type
				Types::Type.create Lib.get_typedef_decl_underlying_type(@cursor), @translation_unit
			end

			def virtual_base?
				Lib.is_virtual_base(@cursor) != 0
			end

			def dynamic_call?
				Lib.is_dynamic_call(@cursor) != 0
			end

			def variadic?
				Lib.is_variadic(@cursor) != 0
			end

			def definition?
				Lib.is_definition(@cursor) != 0
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

			def enum_unsigned_value
				Lib.get_enum_unsigned_value @cursor
			end

			def enum_type
				Types::Type.create Lib.get_enum_decl_integer_type(@cursor), @translation_unit
			end

			def specialized_template
				Cursor.new Lib.get_specialized_cursor_template(@cursor), @translation_unit
			end

			def canonical
				Cursor.new Lib.get_canonical_cursor(@cursor), @translation_unit
			end

			def definition
				Cursor.new Lib.get_cursor_definition(@cursor), @translation_unit
			end

			def opaque_declaration?
				# Is this a declaration that does not have a definition in the translation unit
				self.declaration? && !self.definition? && self.definition.invalid?
			end

			def forward_declaration?
				# Is this a forward declaration for a definition contained in the same translation_unit?
				# https://joshpeterson.github.io/identifying-a-forward-declaration-with-libclang
				#
				# Possible alternate implementations?
				# self.declaration? && !self.definition? && self.definition
				# !self.definition? && self.definition
				self.declaration? && !self.eql?(self.definition) && !self.definition.invalid?
			end

			def referenced
				Cursor.new Lib.get_cursor_referenced(@cursor), @translation_unit
			end

			def semantic_parent
				Cursor.new Lib.get_cursor_semantic_parent(@cursor), @translation_unit
			end

			def lexical_parent
				Cursor.new Lib.get_cursor_lexical_parent(@cursor), @translation_unit
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

			def num_args
				Lib.get_num_args @cursor
			end

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

			def visit_children(&block)
				each(false, &block)
			end

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

			def find_references_in_file(file = nil, &block)
				file ||= Lib.extract_string Lib.get_translation_unit_spelling(@translation_unit)

				visit_adapter = Proc.new do |unused, cxcursor, cxsource_range|
					block.call Cursor.new(cxcursor, @translation_unit), SourceRange.new(cxsource_range)
				end
				visitor = FFI::Clang::Lib::CXCursorAndRangeVisitor.new
				visitor[:visit] = visit_adapter

				Lib.find_references_in_file(@cursor, Lib.get_file(@translation_unit, file), visitor)
			end

			def linkage
				Lib.get_cursor_linkage(@cursor)
			end

			def exception_specification
				Lib.get_cursor_exception_specification_type(@cursor)
			end

			def availability
				Lib.get_cursor_availability(@cursor)
			end

			def included_file
				File.new Lib.get_included_file(@cursor), @translation_unit
			end

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
				[actual_availability_size, max_availability_size].min.times {
					availability << PlatformAvailability.new(cur_ptr)
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

			def overriddens
				cursor_ptr = FFI::MemoryPointer.new :pointer
				num_ptr = FFI::MemoryPointer.new :uint
				Lib.get_overridden_cursors(@cursor, cursor_ptr, num_ptr)
				num = num_ptr.get_uint(0)
				cur_ptr = cursor_ptr.get_pointer(0)

				overriddens = []
				num.times {
					overriddens << Cursor.new(cur_ptr, @translation_unit)
					cur_ptr += Lib::CXCursor.size
				}
				Lib.dispose_overridden_cursors(cursor_ptr.get_pointer(0)) if num != 0
				overriddens
			end

			def bitfield?
				Lib.is_bit_field(@cursor) != 0
			end

			def bitwidth
				Lib.get_field_decl_bit_width(@cursor)
			end

			def overloaded_decl(i)
				Cursor.new Lib.get_overloaded_decl(@cursor, i), @translation_unit
			end

			def num_overloaded_decls
				Lib.get_num_overloaded_decls(@cursor)
			end

			def objc_type_encoding
				Lib.extract_string Lib.get_decl_objc_type_encoding(@cursor)
			end

			def argument(i)
				Cursor.new Lib.cursor_get_argument(@cursor, i), @translation_unit
			end

			def num_arguments
				Lib.cursor_get_num_arguments(@cursor)
			end

			def eql?(other)
				Lib.are_equal(@cursor, other.cursor) != 0
			end
			alias == eql?

			def hash
				Lib.get_cursor_hash(@cursor)
			end

			def to_s
				"Cursor <#{self.kind.to_s.gsub(/^cursor_/, '')}: #{self.spelling}>"
			end

			def references(file = nil)
				refs = []
				self.find_references_in_file(file) do |cursor, unused|
					refs << cursor
					:continue
				end
				refs
			end

			def converting_constructor?
				Lib.is_converting_constructor(@cursor) != 0
			end

			def copy_constructor?
				Lib.is_copy_constructor(@cursor) != 0
			end

			def default_constructor?
				Lib.is_default_constructor(@cursor) != 0
			end

			def move_constructor?
				Lib.is_move_constructor(@cursor) != 0
			end

			def mutable?
				Lib.is_mutable(@cursor) != 0
			end

			def defaulted?
				Lib.is_defaulted(@cursor) != 0
			end

			def deleted?
				Lib.is_deleted(@cursor) != 0
			end

			def copy_assignment_operator?
				Lib.is_copy_assignment_operator(@cursor) != 0
			end

			def move_assignment_operator?
				Lib.is_move_assignment_operator(@cursor) != 0
			end

			def explicit?
				Lib.is_explicit(@cursor) != 0
			end

			def abstract?
				Lib.is_abstract(@cursor) != 0
			end

			def enum_scoped?
				Lib.is_enum_scoped(@cursor) != 0
			end

			def const?
				Lib.is_const(@cursor) != 0
			end

			class PlatformAvailability < AutoPointer
				def initialize(memory_pointer)
					pointer = FFI::Pointer.new(memory_pointer)
					super(pointer)

					# I'm not sure this is safe.
					# Keep a reference to CXPlatformAvailability itself allocated by MemoryPointer.
					@memory_pointer = memory_pointer
					@platform_availability = Lib::CXPlatformAvailability.new(memory_pointer)
				end

				def self.release(pointer)
					# Memory allocated by get_cursor_platform_availability is managed by AutoPointer.
					Lib.dispose_platform_availability(Lib::CXPlatformAvailability.new(pointer))
				end

				def platform
					Lib.get_string @platform_availability[:platform]
				end

				def introduced
					@platform_availability[:introduced]
				end

				def deprecated
					@platform_availability[:deprecated]
				end

				def obsoleted
					@platform_availability[:obsoleted]
				end

				def unavailable
					@platform_availability[:unavailable] != 0
				end

				def message
					Lib.get_string @platform_availability[:message]
				end
			end
		end
	end
end
