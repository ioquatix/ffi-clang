# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2013-2022, by Samuel Williams.

teapot_version "0.8.0"

define_target "ffi-clang" do |target|
	target.depends "Library/clang"
	target.provides "Dependencies/ffi-clang"
end

define_configuration "ffi-clang" do |configuration|
	configuration[:source] = "https://github.com/dream-framework/"
	
	configuration.require "clang"
end
