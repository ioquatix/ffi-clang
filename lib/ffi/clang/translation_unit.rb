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

require 'ffi/clang/lib/translation_unit'
require 'ffi/clang/cursor'
require 'ffi/clang/file'

module FFI
	module Clang
		class TranslationUnit < AutoPointer
			def initialize(pointer, index)
				super pointer
				@index = index
			end

			def self.release(pointer)
				Lib.dispose_translation_unit(pointer)
			end

			def diagnostics
				n = Lib.get_num_diagnostics(self)
			
				n.times.map do |i|
					Diagnostic.new(self, Lib.get_diagnostic(self, i))
				end
			end

			def cursor(location = nil)
				if location.nil?
					Cursor.new Lib.get_translation_unit_cursor(self), self
				else
					Cursor.new Lib.get_cursor(self, location.location), self
				end
			end

			def location(file, line, column)
				ExpansionLocation.new Lib.get_location(self, file, line, column)
			end

			def location_offset(file, offset)
				ExpansionLocation.new Lib.get_location_offset(self, file, offset)
			end

			def file(file_name)
				File.new(Lib.get_file(self, file_name), self)
			end
		end
	end
end
