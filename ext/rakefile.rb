# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2013-2022, by Samuel Williams.

require 'teapot'

task :default do
	controller = Teapot::Controller.new(__dir__)
	
	controller.fetch
	
	packages = ["Dependencies/ffi-clang", "variant-release", "platform-darwin-osx"]
	
	controller.build(packages)
end
