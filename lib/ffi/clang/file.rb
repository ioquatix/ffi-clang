# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2014-2025, by Samuel Williams.

require_relative "lib/file"

module FFI
	module Clang
		# Represents a file in a translation unit.
		class File < Pointer
			# @attribute [TranslationUnit] The translation unit this file belongs to.
			attr_reader :translation_unit
			
			# Initialize a file with a pointer and translation unit.
			# @parameter pointer [FFI::Pointer] The file pointer.
			# @parameter translation_unit [TranslationUnit] The parent translation unit.
			def initialize(pointer, translation_unit)
				super pointer
				@translation_unit = translation_unit
				
				pointer = MemoryPointer.new(Lib::CXFileUniqueID)
				Lib.get_file_unique_id(self, pointer)
				@unique_id = Lib::CXFileUniqueID.new(pointer)
			end
			
			# Get the file name as a string.
			# @returns [String] The file name.
			def to_s
				name
			end
			
			# Get the file name.
			# @returns [String] The file name.
			def name
				Lib.extract_string Lib.get_file_name(self)
			end
			
			# Get the file modification time.
			# @returns [Time] The file modification time.
			def time
				Time.at(Lib.get_file_time(self))
			end
			
			# Check if the file has include guards.
			# @returns [Boolean] True if the file is include guarded.
			def include_guarded?
				Lib.is_file_multiple_include_guarded(@translation_unit, self) != 0
			end
			
			# Get the device ID of the file.
			# @returns [Integer] The device ID.
			def device
				@unique_id[:device]
			end
			
			# Get the inode number of the file.
			# @returns [Integer] The inode number.
			def inode
				@unique_id[:inode]
			end
			
			# Get the modification time from the unique ID.
			# @returns [Time] The modification time.
			def modification
				Time.at(@unique_id[:modification])
			end
		end
	end
end
