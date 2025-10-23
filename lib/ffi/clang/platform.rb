# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "rbconfig"

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
				RUBY_PLATFORM.split("-").last
			end
		end
	end
end
