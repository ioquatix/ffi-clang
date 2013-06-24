# Copyright, 2010-2012 by Jari Bakken.
# Copyright, 2013, by Samuel G. D. Williams. <http://www.codeotaku.com>
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
			def initialize(location)
				@location = location

				cxfile = MemoryPointer.new :pointer
				line   = MemoryPointer.new :uint
				column = MemoryPointer.new :uint
				offset = MemoryPointer.new :uint

				Lib::get_expansion_location(@location, cxfile, line, column, offset)

				@file   = Lib.extract_string Lib.get_file_name(cxfile.read_pointer)
				@line   = line.get_uint(0)
				@column = column.get_uint(0)
				@offset = offset.get_uint(0)
			end

			attr_reader :file, :line, :column, :offset
		end
	end
end
