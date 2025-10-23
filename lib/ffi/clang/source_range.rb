# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010, by Jari Bakken.
# Copyright, 2012, by Hal Brodigan.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2013, by Garry Marshall.
# Copyright, 2014, by Masahiro Sano.

require_relative 'lib/source_range'

module FFI
	module Clang
		# Represents a source range in a file.
		class SourceRange
			# Get a null source range.
			# @returns [SourceRange] A null source range.
			def self.null_range
				SourceRange.new Lib.get_null_range
			end

			# Initialize a source range.
			# @parameter range_or_begin_location [Lib::CXSourceRange | SourceLocation] Either a range structure or the beginning location.
			# @parameter end_location [SourceLocation | Nil] The end location, or `nil` if first parameter is a range.
			def initialize(range_or_begin_location, end_location = nil)
				if end_location.nil?
					@range = range_or_begin_location
				else
					@range = Lib.get_range(range_or_begin_location.location, end_location.location)
				end
			end

			# Get the start location of this range.
			# @returns [ExpansionLocation] The start location.
			def start
				@start ||= ExpansionLocation.new(Lib.get_range_start @range)
			end

			# Get the end location of this range.
			# @returns [ExpansionLocation] The end location.
			def end
				@end ||= ExpansionLocation.new(Lib.get_range_end @range)
			end

			# Get the size in bytes of the source range.
			# @returns [Integer] The byte size.
			def bytesize
				self.end.offset - self.start.offset
			end

			# Read the text from the source file for this range.
			# @returns [String] The source text.
			def text
				::File.open(self.start.file, "r") do |file|
					file.seek(self.start.offset)
					return file.read(self.bytesize)
				end
			end

			# Check if this range is null.
			# @returns [Boolean] True if the range is null.
			def null?
				Lib.range_is_null(@range) != 0
			end

			# @attribute [Lib::CXSourceRange] The underlying range structure.
			attr_reader :range

			# Check if this range equals another range.
			# @parameter other [SourceRange] The range to compare with.
			# @returns [Boolean] True if the ranges are equal.
			def ==(other)
				Lib.equal_range(@range, other.range) != 0
			end
		end
	end
end
