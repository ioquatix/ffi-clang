# -*- coding: utf-8 -*-
# Copyright, 2013, by Carlos Martín Nieto <cmn@dwim.me>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'ffi/clang/lib/cursor'
require 'ffi/clang/lib/comment'
require 'ffi/clang/source_location'

module FFI
	module Clang

		class Comment
			include Enumerable

			def self.build_from(comment)
				kind = Lib.comment_get_kind(comment)
				case kind
				when :comment_full
					FullComment.new comment
				when :comment_paragraph
					ParagraphComment.new comment
				when :comment_text
					TextComment.new comment
				when :comment_block_command
					BlockCommandComment.new comment
				when :comment_param_command
					ParamCommandComment.new comment
				when :comment_null
					Comment.new comment
				else
					raise NotImplementedError, kind
				end
			end

			def initialize(comment)
				@comment = comment
			end

			def kind
				Lib.comment_get_kind(@comment)
			end

			def paragraph
				Comment.build_from Lib.block_command_comment_get_paragraph(@comment)
			end

			def num_children
				Lib.comment_get_num_children(@comment)
			end

			def child(n = 0)
				Comment.build_from Lib.comment_get_child(@comment, n)
			end

			def each(&block)
				(0..num_children-1).map do |i|
					block.call(child(i))
				end
			end

		end

		class ParagraphComment < Comment
			def text
				self.map(&:text).join("\n")
			end
		end

		class TextComment < Comment
			def text
				Lib.extract_string Lib.text_comment_get_text(@comment)
			end
		end

		class BlockCommandComment < Comment
			def name
				Lib.extract_string Lib.block_command_comment_get_command_name(@comment)
			end
		end

		class ParamCommandComment < Comment
			def name
				Lib.extract_string Lib.param_command_comment_get_param_name(@comment)
			end
		end

		class FullComment < Comment
			def to_html
				Lib.extract_string Lib.full_comment_get_as_html(@comment)
			end

			def to_xml
				Lib.extract_string Lib.full_comment_get_as_xml(@comment)
			end
		end

	end
end
