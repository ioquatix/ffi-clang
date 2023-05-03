# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010, by Jari Bakken.
# Copyright, 2012, by Hal Brodigan.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2013, by Dave Wilkinson.
# Copyright, 2013, by Takeshi Watanabe.
# Copyright, 2014, by Masahiro Sano.

require_relative 'lib/index'

module FFI
	module Clang
		class Index < AutoPointer
			def initialize(exclude_declarations = true, display_diagnostics = false)
				super Lib.create_index(exclude_declarations ? 1 : 0, display_diagnostics ? 1 : 0)
			end

			def self.release(pointer)
				Lib.dispose_index(pointer)
			end

			def parse_translation_unit(source_file, command_line_args = nil, unsaved = [], opts = [])
				command_line_args = Array(command_line_args)
				unsaved_files = UnsavedFile.unsaved_pointer_from(unsaved)

				translation_unit_pointer = Lib.parse_translation_unit(self, source_file, args_pointer_from(command_line_args), command_line_args.size, unsaved_files, unsaved.length, options_bitmask_from(opts))

				raise Error, "error parsing #{source_file.inspect}" if translation_unit_pointer.null?

				TranslationUnit.new translation_unit_pointer, self
			end

			def create_translation_unit(ast_filename)
				translation_unit_pointer = Lib.create_translation_unit(self, ast_filename)
				raise Error, "error parsing #{ast_filename.inspect}" if translation_unit_pointer.null?
				TranslationUnit.new translation_unit_pointer, self
			end

			private

			def args_pointer_from(command_line_args)
				args_pointer = MemoryPointer.new(:pointer, command_line_args.length)

				strings = command_line_args.map do |arg|
					MemoryPointer.from_string(arg.to_s)
				end

				args_pointer.put_array_of_pointer(0, strings) unless strings.empty?
				args_pointer
			end

			def options_bitmask_from(opts)
				Lib.bitmask_from(Lib::TranslationUnitFlags, opts)
			end
		end
	end
end
