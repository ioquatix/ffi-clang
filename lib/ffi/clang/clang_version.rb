# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2022, by Samuel Williams.

require_relative 'lib/clang_version'

module FFI
	module Clang
		def self.clang_version_string
			Lib.extract_string Lib.get_clang_version
		end
	end
end
