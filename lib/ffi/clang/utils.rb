# Copyright, 2014 by Masahiro Sano.
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

require 'ffi/clang/lib/utils'
require 'ffi/clang/lib/string'

module FFI
	module Clang
		class Utils
			def self.clang_version_string
				Lib.extract_string Lib.get_clang_version
			end

			def self.clang_version
				version = clang_version_string
				version.match(/based on LLVM (\d+\.\d+)/).values_at(1).first
			end

			def self.clang_version_symbol
				version = "clang_" + clang_version.tr('.', '_')
				version.intern
			end

			def self.clang_major_version
				version = clang_version_string
				version.match(/based on LLVM (\d+)\./).values_at(1).first.to_i
			end

			def self.clang_minor_version
				version = clang_version_string
				version.match(/based on LLVM \d+\.(\d+)/).values_at(1).first.to_i
			end

			def self.satisfy_version?(min_version, max_version = nil)
				Gem::Version.create(self.clang_version) >= Gem::Version.create(min_version) and
					(max_version.nil? or
					Gem::Version.create(self.clang_version) <= Gem::Version.create(max_version))
			end
		end
	end
end
