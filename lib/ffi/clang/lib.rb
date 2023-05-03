# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010-2012, by Jari Bakken.
# Copyright, 2012, by Hal Brodigan.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2013-2014, by Carlos Martín Nieto.
# Copyright, 2013, by Takeshi Watanabe.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2014, by Greg Hazel.
# Copyright, 2014, by Niklas Therning.
# Copyright, 2016, by Mike Dalessio.
# Copyright, 2019, by Hayden Purdy.
# Copyright, 2019, by Dominic Sisnero.
# Copyright, 2020, by Luikore.

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
				%W[
					#{xcode_dir}/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang.dylib
					#{xcode_dir}/usr/lib/libclang.dylib
				].each do |f|
					if File.exist? f
						libs << f
						break
					end
				end
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

				opts.each do |symbol|
					if int = enum[symbol]
						bitmask |= int
					else
  						raise Error, "unknown option: #{symbol}, expected one of #{enum.symbols}"
					end
				end

				bitmask
			end

			def self.opts_from(enum, bitmask)
				bit = 1
				result = []
				while bitmask != 0
					if bitmask & 1
						if symbol = enum[bit]
							result << symbol
						else
							raise(Error, "unknown values: #{bit}, expected one of #{enum.symbols}")
						end
					end
					bitmask >>= 1
					bit <<= 1
				end
				result
			end
		end
	end
end
