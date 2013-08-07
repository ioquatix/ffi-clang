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
		module Lib
			extend FFI::Library

			libs = ["clang"]

			if Clang.platform == :linux
				libs += [
					"/usr/lib/llvm-3.3/lib/libclang.so",
					"/usr/lib64/llvm-3.3/lib/libclang.so"
				]
			end

			ffi_lib libs

			def self.bitmask_from(enum, opts)
				bitmask = 0

				opts.each do |key, val|
					next unless val

					if int = enum[key]
						bitmask |= int
					else
						raise Error, "unknown option: #{key.inspect}, expected one of #{enum.symbols}"
					end
				end

				bitmask
			end
		end
	end
end
