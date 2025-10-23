# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010, by Jari Bakken.
# Copyright, 2012, by Hal Brodigan.
# Copyright, 2013-2024, by Samuel Williams.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2013, by Dave Wilkinson.
# Copyright, 2013, by Takeshi Watanabe.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2023, by Charlie Savage.

require_relative 'lib/index'
require_relative "error"

module FFI
	module Clang
		# Represents a libclang index that manages translation units and provides a top-level context for parsing.
		class Index < AutoPointer
			# Initialize a new index for managing translation units.
			# @parameter exclude_declarations [Boolean] Whether to exclude declarations from PCH.
			# @parameter display_diagnostics [Boolean] Whether to display diagnostics during parsing.
			def initialize(exclude_declarations = true, display_diagnostics = false)
				super Lib.create_index(exclude_declarations ? 1 : 0, display_diagnostics ? 1 : 0)
			end

			# Release the index pointer.
			# @parameter pointer [FFI::Pointer] The index pointer to release.
			def self.release(pointer)
				Lib.dispose_index(pointer)
			end

			# Parse a source file and create a translation unit.
			# @parameter source_file [String] The path to the source file to parse.
			# @parameter command_line_args [Array(String) | String | Nil] Compiler arguments for parsing.
			# @parameter unsaved [Array(UnsavedFile)] Unsaved file buffers.
			# @parameter opts [Hash] Parsing options as a hash of flags.
			# @returns [TranslationUnit] The parsed translation unit.
			# @raises [Error] If parsing fails.
			def parse_translation_unit(source_file, command_line_args = nil, unsaved = [], opts = {})
				command_line_args = Array(command_line_args)
				unsaved_files = UnsavedFile.unsaved_pointer_from(unsaved)

				translation_unit_pointer_out = FFI::MemoryPointer.new(:pointer)

				error_code = Lib.parse_translation_unit2(self, source_file, args_pointer_from(command_line_args), command_line_args.size, unsaved_files, unsaved.length, options_bitmask_from(opts), translation_unit_pointer_out)
				if error_code != :cx_error_success
					error_name = Lib::ErrorCodes.from_native(error_code, nil)
					message = "Error parsing file. Code: #{error_name}. File: #{source_file.inspect}"
					raise(Error, message)
				end

				translation_unit_pointer = translation_unit_pointer_out.read_pointer
				TranslationUnit.new translation_unit_pointer, self
			end

			# Create a translation unit from a precompiled AST file.
			# @parameter ast_filename [String] The path to the AST file.
			# @returns [TranslationUnit] The loaded translation unit.
			# @raises [Error] If loading the AST file fails.
			def create_translation_unit(ast_filename)
				translation_unit_pointer = Lib.create_translation_unit(self, ast_filename)
				raise Error, "error parsing #{ast_filename.inspect}" if translation_unit_pointer.null?
				TranslationUnit.new translation_unit_pointer, self
			end

			private

			# Convert command line arguments to a pointer array for libclang.
			# @parameter command_line_args [Array(String)] The command line arguments.
			# @returns [FFI::MemoryPointer] A pointer to the arguments array.
			def args_pointer_from(command_line_args)
				args_pointer = MemoryPointer.new(:pointer, command_line_args.length)

				strings = command_line_args.map do |arg|
					MemoryPointer.from_string(arg.to_s)
				end

				args_pointer.put_array_of_pointer(0, strings) unless strings.empty?
				args_pointer
			end

			# Convert options hash to a bitmask for libclang.
			# @parameter opts [Hash] The options hash.
			# @returns [Integer] The bitmask representing the options.
			def options_bitmask_from(opts)
				Lib.bitmask_from(Lib::TranslationUnitFlags, opts)
			end
		end
	end
end
