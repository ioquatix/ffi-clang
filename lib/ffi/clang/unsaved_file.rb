# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2013-2025, by Samuel Williams.
# Copyright, 2014, by Masahiro Sano.

module FFI
	module Clang
		# Represents an unsaved file with in-memory contents for parsing.
		class UnsavedFile
			# Initialize an unsaved file with filename and contents.
			# @parameter filename [String] The path to the unsaved file.
			# @parameter contents [String] The in-memory contents of the file.
			def initialize(filename, contents)
				@filename = filename
				@contents = contents
			end
			
			# @attribute [String] The path to the unsaved file.
			attr_accessor :filename
			
			# @attribute [String] The in-memory contents of the file.
			attr_accessor :contents
			
			# Convert an array of unsaved files to a libclang pointer structure.
			# @parameter unsaved [Array(UnsavedFile)] The array of unsaved files.
			# @returns [FFI::MemoryPointer | Nil] A pointer to the unsaved file structures, or `nil` if empty.
			def self.unsaved_pointer_from(unsaved)
				return nil if unsaved.length == 0
				
				vec = MemoryPointer.new(Lib::CXUnsavedFile, unsaved.length)
				
				unsaved.each_with_index do |file, i|
					uf = Lib::CXUnsavedFile.new(vec + i * Lib::CXUnsavedFile.size)
					uf[:filename] = MemoryPointer.from_string(file.filename)
					uf[:contents] = MemoryPointer.from_string(file.contents)
					uf[:length] = file.contents.length
				end
				
				vec
			end
		end
	end
end
