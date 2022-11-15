# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2014-2022, by Samuel Williams.

require_relative 'lib/token'
require_relative 'lib/cursor'
require_relative 'source_location'

module FFI
	module Clang
		class Tokens < AutoPointer
			include Enumerable

			attr_reader :size
			attr_reader :tokens

			def initialize(pointer, token_size, translation_unit)
				ptr = Lib::TokensPointer.new(pointer,token_size, translation_unit)
				super ptr

				@translation_unit = translation_unit
				@size = token_size

				@tokens = []
				cur_ptr = pointer
				token_size.times {
					@tokens << Token.new(cur_ptr, translation_unit)
					cur_ptr += Lib::CXToken.size
				}
			end

			def self.release(pointer)
				Lib.dispose_tokens(pointer.translation_unit, pointer, pointer.token_size)
			end

			def each(&block)
				@tokens.each do |token|
					block.call(token)
				end
			end

			def cursors
				ptr = MemoryPointer.new(Lib::CXCursor, @size)
				Lib.annotate_tokens(@translation_unit, self, @size, ptr)

				cur_ptr = ptr
				arr = []
				@size.times {
					arr << Cursor.new(cur_ptr, @translation_unit)
					cur_ptr += Lib::CXCursor.size
				}
				arr
			end
		end

		class Token
			def initialize(token, translation_unit)
				@token = token
				@translation_unit = translation_unit
			end

			def kind
				Lib.get_token_kind(@token)
			end

			def spelling
				Lib.extract_string Lib.get_token_spelliing(@translation_unit, @token)
			end

			def location
				ExpansionLocation.new Lib.get_token_location(@translation_unit, @token)
			end

			def extent
				SourceRange.new Lib.get_token_extent(@translation_unit, @token)
			end
		end
	end
end
