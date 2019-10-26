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

require 'mkmf'

module FFI
	module Clang
		module Lib
			extend FFI::Library
			
			# Use LLVM_CONFIG if it was explicitly specified:
			llvm_config = ENV['LLVM_CONFIG']
			
			# If we aren't building for a specific version (e.g. travis) try to find llvm-config
			unless ENV['LLVM_VERSION'] 
				 llvm_config ||= MakeMakefile.find_executable0("llvm-config")
			end

			libs = []
			begin
				xcode_dir = `xcode-select -p`.chomp
				libs << "#{xcode_dir}/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang.dylib"
			rescue Errno::ENOENT
				# Ignore
			end

			libs << "clang"

			if ENV['LIBCLANG']
				libs << ENV['LIBCLANG']
			elsif llvm_config
				llvm_library_dir = `#{llvm_config} --libdir`.chomp
				platform = FFI::Clang.platform
				
				case platform
				when :darwin
					libs << llvm_library_dir + '/libclang.dylib'
				when :windows
					llvm_bin_dir = `#{llvm_config} --bindir`.chomp
					libs << llvm_bin_dir + '/libclang.dll'
				else
					libs << llvm_library_dir + '/libclang.so'
				end
			end

			ffi_lib libs

			def self.bitmask_from(enum, opts)
				bitmask = 0

				opts.each do |key, value|
					if int = enum[key]
						bitmask |= int
					else
						raise Error, "unknown option: #{key.inspect}, expected one of #{enum.symbols}"
					end
				end

				bitmask
			end

			def self.opts_from(enum, bitmask)
				bit = 1
				opts = {}
				while bitmask != 0
					if bitmask & 1
						if sym = enum[bit]
							opts[sym] = true
						else
							raise Error, "unknown values: #{bit}, expected one of #{enum.symbols}"
						end
					end
					bitmask >>= 1
					bit <<= 1
				end
				opts
			end
		end
	end
end
