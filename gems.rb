# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010, by Jari Bakken.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2020, by Luikore.

source 'https://rubygems.org'

gemspec

group :maintenance, optional: true do
	gem "bake-gem"
	gem "bake-modernize"
end

group :test do
	gem 'simplecov'
end
