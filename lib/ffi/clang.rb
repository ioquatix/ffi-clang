# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010-2011, by Jari Bakken.
# Copyright, 2012, by Hal Brodigan.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2013, by Garry Marshall.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2014, by Masahiro Sano.

require 'ffi'
require 'rbconfig'

module FFI::Clang
	class Error < StandardError
	end

	def self.platform
		os = RbConfig::CONFIG["host_os"]

		case os
		when /darwin/
			:darwin
		when /linux/
			:linux
		when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
			:windows
		else
			os
		end
	end
end

# Load the shared object:
require_relative 'clang/lib'

# Wrappers around C functionality:
require_relative 'clang/clang_version'
require_relative 'clang/index'
require_relative 'clang/translation_unit'
require_relative 'clang/diagnostic'
require_relative 'clang/cursor'
require_relative 'clang/source_location'
require_relative 'clang/source_range'
require_relative 'clang/unsaved_file'
require_relative 'clang/token'
require_relative 'clang/code_completion'
require_relative 'clang/compilation_database'
