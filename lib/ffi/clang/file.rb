# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2014-2022, by Samuel Williams.

require_relative 'lib/file'

module FFI
	module Clang
		class File < Pointer
			attr_reader :translation_unit

			def initialize(pointer, translation_unit)
				super pointer
				@translation_unit = translation_unit

				pointer = MemoryPointer.new(Lib::CXFileUniqueID)
				Lib.get_file_unique_id(self, pointer)
				@unique_id = Lib::CXFileUniqueID.new(pointer)
			end

			def to_s
				name
			end

			def name
				Lib.extract_string Lib.get_file_name(self)
			end

			def time
				Time.at(Lib.get_file_time(self))
			end

			def include_guarded?
				Lib.is_file_multiple_include_guarded(@translation_unit, self) != 0
			end

			def device
				@unique_id[:device]
			end

			def inode
				@unique_id[:inode]
			end

			def modification
				Time.at(@unique_id[:modification])
			end
		end
	end
end
