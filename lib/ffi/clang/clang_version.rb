# Copyright, 2016, by Samuel G. D. Williams. <http: //www.codeotaku.com>

# Released under the MIT License.
# Copyright, 2016-2022, by Samuel Williams.

# Released under the MIT License.
# Copyright, 2016, by Samuel Williams.

require_relative 'lib/clang_version'

module FFI
	module Clang
		def self.clang_version_string
			Lib.extract_string Lib.get_clang_version
		end
	end
end
