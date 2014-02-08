# -*- coding: utf-8 -*-
# Copyright, 2013, by Carlos Martín Nieto <cmn@dwim.me.
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

module FFI
	module Clang
		class UnsavedFile
			def initialize(filename, contents)
				@filename = filename
				@contents = contents
			end

			attr_accessor :filename, :contents


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
