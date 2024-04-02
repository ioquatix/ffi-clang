# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010, by Jari Bakken.
# Copyright, 2013-2024, by Samuel Williams.
# Copyright, 2020, by Zete Lui.

source 'https://rubygems.org'

gemspec

gem "rake"

group :maintenance, optional: true do
	gem "bake-gem"
	gem "bake-modernize"
end

group :test do
	gem "bake-test"
	gem "rspec", ">= 3.4.0"
	gem 'simplecov'
end
