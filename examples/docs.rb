#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2025, by Samuel Williams.

require "rainbow"
require "ffi/clang"

index = FFI::Clang::Index.new

# clang -Xclang -ast-dump -fsyntax-only ./examples/docs.cpp

def title(declaration)
	puts ["Symbol:", Rainbow(declaration.spelling).blue.bright, "Type:", Rainbow(declaration.type.spelling).green, declaration.kind.to_s].join(" ")
end

ARGV.each do |path|
	translation_unit = index.parse_translation_unit(path)
	
	declarations = translation_unit.cursor.select(&:declaration?)
	
	declarations.each do |declaration|
		title declaration
		
		if location = declaration.location
			puts "Defined at #{location.file}:#{location.line}"
		end
		
		if comment = declaration.comment
			# puts Rainbow(comment.inspect).gray
			puts Rainbow(comment.text)
		end
	end
end
