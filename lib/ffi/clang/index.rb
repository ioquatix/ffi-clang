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

require 'ffi/clang/lib/index'

module FFI
	module Clang
		class Index < AutoPointer
			def initialize(exclude_declarations = true, display_diagnostics = false)
				super Lib.create_index(exclude_declarations ? 1 : 0, display_diagnostics ? 1 : 0)
			end

			def self.release(pointer)
				Lib.dispose_index_debug(pointer)
			end

			def parse_translation_unit(source_file, command_line_args = nil, unsaved = [], opts = {})
				command_line_args = Array(command_line_args)
				unsaved_files = unsaved_pointer_from(unsaved)

				translation_unit_pointer = Lib.parse_translation_unit(self, source_file, args_pointer_from(command_line_args), command_line_args.size, unsaved_files, unsaved.length, options_bitmask_from(opts))

				raise Error, "error parsing #{source_file.inspect}" if translation_unit_pointer.null?

				TranslationUnit.new translation_unit_pointer, self
			end

			private

			def args_pointer_from(command_line_args)
				args_pointer = MemoryPointer.new(:pointer, command_line_args.length)

				strings = command_line_args.map do |arg|
					MemoryPointer.from_string(arg.to_s)
				end

				args_pointer.put_array_of_pointer(0, strings) unless strings.empty?
				args_pointer
			end

			def options_bitmask_from(opts)
				Lib.bitmask_from Lib::TranslationUnitFlags, opts
			end

			def unsaved_pointer_from(unsaved)
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
