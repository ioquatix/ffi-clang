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

require_relative 'lib/file'
require_relative 'utils'

module FFI
	module Clang
		class File < Pointer
			attr_reader :translation_unit

			def initialize(pointer, translation_unit)
				super pointer
				@translation_unit = translation_unit

				if FFI::Clang::Utils.satisfy_version?('3.3')
					pointer = MemoryPointer.new(Lib::CXFileUniqueID)
					Lib.get_file_unique_id(self, pointer)
					@unique_id = Lib::CXFileUniqueID.new(pointer)
				end
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
