# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2024, by Samuel Williams.
# Copyright, 2023, by Charlie Savage.

require_relative 'lib/clang_version'

module FFI
	module Clang
		# Get the version string of the libclang library.
		# @returns [String] The libclang version string.
		def self.clang_version_string
			Lib.extract_string Lib.get_clang_version
		end

		# Get the libclang version as a Gem::Version object.
		# @returns [Gem::Version] The parsed version.
		def self.clang_version
			clang_version = self.clang_version_string.match(/\d+\.\d+\.\d+/)
			Gem::Version.new(clang_version)
		end
	end
end
