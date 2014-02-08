# Copyright, 2010-2012 by Jari Bakken.
# Copyright, 2013, by Samuel G. D. Williams. <http://www.codeotaku.com>
# Copyright, 2014, by Masahiro Sano.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'ffi/clang/lib/source_location'
require 'ffi/clang/lib/file'

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

			def expansion_location
				ExpansionLocation.new(@location)
			end

			def presumed_location
				PresumedLocation.new(@location)
			end

			def spelling_location
				SpellingLocation.new(@location)
			end

			def file_location
				FileLocation.new(@location)
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
		end

		class PresumedLocation < SourceLocation
			attr_reader :filename, :line, :column, :offset

			def initialize(location)
				super(location)

				cxstring = MemoryPointer.new Lib::CXString
				line	 = MemoryPointer.new :uint
				column	 = MemoryPointer.new :uint

				Lib::get_presumed_location(@location, cxstring, line, column)

				@filename = Lib.extract_string cxstring
				@line = line.get_uint(0)
				@column = column.get_uint(0)
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
		end
	end
end
