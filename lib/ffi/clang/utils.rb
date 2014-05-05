# Copyright, 2014 by Masahiro Sano.
# Copyright, 2014 by Samuel Williams.
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
		module Utils
			@@clang_version = nil
			
			def self.clang_version_string
				Lib.extract_string Lib.get_clang_version
			end

			def self.clang_version
				unless @@clang_version
					# Version string vary wildy:
					# Ubuntu: "Ubuntu clang version 3.0-6ubuntu3 (tags/RELEASE_30/final) (based on LLVM 3.0)"
					# Mac OS X: "Apple LLVM version 5.0 (clang-500.2.79) (based on LLVM 3.3svn)"
					# Linux: "clang version 3.3"
				
					if parts = clang_version_string.match(/(?:clang version|based on LLVM) (\d+)\.(\d+)(svn)?/)
						major = parts[1].to_i
						minor = parts[2].to_i
						rc = parts[3]
					
						# Mac OS X currently reports support for 3.3svn, but this support is broken in some ways, so we revert it back to 3.2 which it supports completely.
						if rc == 'svn'
							minor -= 1
						end
					
						@@clang_version = [major, minor]
						
						puts "Using libclang: #{Lib::ffi_libraries[0].name}"
						puts "Clang version detected: #{@@clang_version.inspect}"
					else
						abort "Invalid/unsupported clang version string."
					end
				end
				
				return @@clang_version
			end

			def self.clang_version_symbol
				"clang_#{clang_version.join('_')}".to_sym
			end

			def self.clang_major_version
				clang_version[0]
			end

			def self.clang_minor_version
				clang_version[1]
			end

			# Returns true if the current clang version is >= min version and optionally <= max_version
			def self.satisfy_version?(min_version, max_version = nil)
				min_version = Gem::Version.create(min_version)
				max_version = Gem::Version.create(max_version) if max_version
				current_version = Gem::Version.create(self.clang_version.join('.'))
				
				return (current_version >= min_version) && (!max_version || current_version <= max_version)
			end
		end
	end
end
