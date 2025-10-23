# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010-2011, by Jari Bakken.
# Copyright, 2012, by Hal Brodigan.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2013, by Garry Marshall.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2014, by Masahiro Sano.

require 'rbconfig'

module FFI
	module Clang
		# Get the current platform identifier.
		# @returns [Symbol] The platform identifier (`:darwin`, `:linux`, `:windows`, or a custom platform string).
		def self.platform
			case RUBY_PLATFORM
			when /darwin/
				:darwin
			when /linux/
				:linux
			when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
				:windows
			else
				RUBY_PLATFORM.split('-').last
			end
		end
	end
end
