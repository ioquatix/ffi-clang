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

module FFI
	module Clang
		class Index
			def initialize(opts = {})
				exclude_declarations_from_pch = opts[:exclude_declarations_from_pch] ? 1 : 0
				display_diagnostics = opts[:display_diagnostics] ? 1 : 0

				@ptr = AutoPointer.new Lib.create_index(exclude_declarations_from_pch, display_diagnostics),
				Lib.method(:dispose_index_debug)
			end

			def parse_translation_unit(source_file, command_line_args = nil, opts = {})
				command_line_args = Array(command_line_args)

				tu = Lib.parse_translation_unit(@ptr,
				source_file,
				args_pointer_from(command_line_args),
				command_line_args.size, nil, 0, options_bitmask_from(opts))

				raise Error, "error parsing #{source_file.inspect}" if tu.nil? || tu.null?

				TranslationUnit.new tu
			end

			private

			def args_pointer_from(command_line_args)
				args_pointer = MemoryPointer.new(:pointer)

				strings = command_line_args.map do |arg|
					MemoryPointer.from_string(arg.to_s)
				end

				args_pointer.put_array_of_pointer(strings) unless strings.empty?
				args_pointer
			end

			def options_bitmask_from(opts)
				Lib.bitmask_from Lib::TranslationUnitFlags, opts
			end

		end
	end
end
