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
		class SourceRange
			def self.null_range
				SourceRange.new Lib.get_null_range
			end

			def initialize(range_or_begin_location, end_location = nil)
				if end_location.nil?
					@range = range_or_begin_location
				else
					@range = Lib.get_range(range_or_begin_location.location, end_location.location)
				end
			end

			def start
				@start ||= ExpansionLocation.new(Lib.get_range_start @range)
			end

			def end
				@end ||= ExpansionLocation.new(Lib.get_range_end @range)
			end

			# The size, in bytes, of the source range.
			def bytesize
				self.end.offset - self.start.offset
			end

			# Read the part of the source file referred to by this source range.
			def text
				::File.open(self.start.file, "r") do |file|
					file.seek(self.start.offset)
					return file.read(self.bytesize)
				end
			end

			def null?
				Lib.range_is_null(@range) != 0
			end

			attr_reader :range

			def ==(other)
				Lib.equal_range(@range, other.range) != 0
			end
		end
	end
end
