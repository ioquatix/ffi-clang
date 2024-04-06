# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010, by Jari Bakken.
# Copyright, 2012, by Hal Brodigan.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2013, by Garry Marshall.
# Copyright, 2014, by Masahiro Sano.

require_relative 'lib/source_location'
require_relative 'lib/file'

module FFI
	module Clang
		class SourceLocation
			def self.null_location
				ExpansionLocation.new Lib.get_null_location
			end

			attr_reader :location
			def initialize(location)
				@location = location
			end

			def in_system_header?
				Lib.location_in_system_header(@location) != 0
			end

			def from_main_file?
				Lib.location_is_from_main_file(@location) != 0
			end

			def null?
				Lib.equal_locations(@location, Lib.get_null_location) != 0
			end

			def ==(other)
				Lib.equal_locations(@location, other.location) != 0
			end
		end

		class ExpansionLocation < SourceLocation
			attr_reader :file, :line, :column, :offset

			def initialize(location)
				super(location)

				cxfile = MemoryPointer.new :pointer
				line   = MemoryPointer.new :uint
				column = MemoryPointer.new :uint
				offset = MemoryPointer.new :uint

				Lib::get_expansion_location(@location, cxfile, line, column, offset)

				@file = Lib.extract_string Lib.get_file_name(cxfile.read_pointer)
				@line = line.get_uint(0)
				@column = column.get_uint(0)
				@offset = offset.get_uint(0)
			end

			def as_string
				"#{@file}:#{@line}:#{@column}:#{@offset}"
			end

			def to_s
				"ExpansionLocation <#{self.as_string}>"
			end
		end

		class PresumedLocation < SourceLocation
			attr_reader :filename, :line, :column, :offset

			def initialize(location)
				super(location)

				cxstring = MemoryPointer.new Lib::CXString
				line   = MemoryPointer.new :uint
				column   = MemoryPointer.new :uint

				Lib::get_presumed_location(@location, cxstring, line, column)

				@filename = Lib.extract_string cxstring
				@line = line.get_uint(0)
				@column = column.get_uint(0)
			end

			def as_string
				"#{@filename}:#{@line}:#{@column}"
			end

			def to_s
				"PresumedLocation <#{self.as_string}>"
			end
		end

		class SpellingLocation < SourceLocation
			attr_reader :file, :line, :column, :offset

			def initialize(location)
				super(location)

				cxfile = MemoryPointer.new :pointer
				line   = MemoryPointer.new :uint
				column = MemoryPointer.new :uint
				offset = MemoryPointer.new :uint

				Lib::get_spelling_location(@location, cxfile, line, column, offset)

				@file = Lib.extract_string Lib.get_file_name(cxfile.read_pointer)
				@line = line.get_uint(0)
				@column = column.get_uint(0)
				@offset = offset.get_uint(0)
			end

			def as_string
				"#{@file}:#{@line}:#{@column}:#{@offset}"
			end

			def to_s
				"SpellingLocation <#{self.as_string}>"
			end
		end

		class FileLocation < SourceLocation
			attr_reader :file, :line, :column, :offset

			def initialize(location)
				super(location)

				cxfile = MemoryPointer.new :pointer
				line   = MemoryPointer.new :uint
				column = MemoryPointer.new :uint
				offset = MemoryPointer.new :uint

				Lib::get_file_location(@location, cxfile, line, column, offset)

				@file = Lib.extract_string Lib.get_file_name(cxfile.read_pointer)
				@line = line.get_uint(0)
				@column = column.get_uint(0)
				@offset = offset.get_uint(0)
			end

			def as_string
				"#{@file}:#{@line}:#{@column}:#{@offset}"
			end

			def to_s
				"FileLocation <#{self.as_string}>"
			end
		end
	end
end
