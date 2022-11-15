# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2014, by George Pimm.
# Copyright, 2014, by Masahiro Sano.

require_relative 'lib/cursor'
require_relative 'lib/comment'
require_relative 'source_location'

module FFI
	module Clang

		class Comment
			include Enumerable

			def self.build_from(comment)
				kind = Lib.comment_get_kind(comment)
				case kind
				when :comment_null
					Comment.new comment
				when :comment_text
					TextComment.new comment
				when :comment_inline_command
					InlineCommandComment.new comment
				when :comment_html_start_tag
					HTMLStartTagComment.new comment
				when :comment_html_end_tag
					HTMLEndTagComment.new comment
				when :comment_paragraph
					ParagraphComment.new comment
				when :comment_block_command
					BlockCommandComment.new comment
				when :comment_param_command
					ParamCommandComment.new comment
				when :comment_tparam_command
					TParamCommandComment.new comment
				when :comment_verbatim_block_command
					VerbatimBlockCommandComment.new comment
				when :comment_verbatim_block_line
					VerbatimBlockLineComment.new comment
				when :comment_verbatim_line
					VerbatimLine.new comment
				when :comment_full
					FullComment.new comment
				else
					raise NotImplementedError, kind
				end
			end

			def text
				return ""
			end

			def initialize(comment)
				@comment = comment
			end

			def kind
				Lib.comment_get_kind(@comment)
			end

			def num_children
				Lib.comment_get_num_children(@comment)
			end

			def child(n = 0)
				Comment.build_from Lib.comment_get_child(@comment, n)
			end

			def children
				num_children.times.map { |i| child(i) }
			end

			def whitespace?
				Lib.comment_is_whitespace(@comment) != 0
			end

			def has_trailing_newline?
				Lib.inline_content_comment_has_trailing_newline(@comment) != 0
			end

			def each(&block)
				num_children.times.map do |i|
					block.call(child(i))
				end
			end

		end

		class HTMLTagComment < Comment
			def name
				Lib.extract_string Lib.html_tag_comment_get_tag_name(@comment)
			end
			alias_method :tag, :name

			def text
				Lib.extract_string Lib.html_tag_comment_get_as_string(@comment)
			end
		end

		class HTMLStartTagComment < HTMLTagComment
			def self_closing?
				Lib.html_start_tag_comment_is_self_closing(@comment) != 0
			end

			def num_attrs
				Lib.html_start_tag_comment_get_num_attrs(@comment)
			end

			def attrs
				num_attrs.times.map { |i|
					{
						name: Lib.extract_string(Lib.html_start_tag_comment_get_attr_name(@comment, i)),
						value: Lib.extract_string(Lib.html_start_tag_comment_get_attr_value(@comment, i)),
					}
			  }
			end
		end

		class HTMLEndTagComment < HTMLTagComment
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

		class InlineCommandComment < Comment
			def name
				Lib.extract_string Lib.inline_command_comment_get_command_name(@comment)
			end

			def render_kind
				Lib.inline_command_comment_get_render_kind(@comment)
			end

			def num_args
				Lib.inline_command_comment_get_num_args(@comment)
			end

			def args
				num_args.times.map { |i|
					Lib.extract_string Lib.inline_command_comment_get_arg_text(@comment, i)
				}
			end

			def text
				args.join
			end
		end

		class BlockCommandComment < Comment
			def name
				Lib.extract_string Lib.block_command_comment_get_command_name(@comment)
			end

			def paragraph
				Comment.build_from Lib.block_command_comment_get_paragraph(@comment)
			end

			def text
				self.paragraph.text
			end
			alias_method :comment, :text

			def num_args
				Lib.block_command_comment_get_num_args(@comment)
			end

			def args
				num_args.times.map { |i|
					Lib.extract_string Lib.block_command_comment_get_arg_text(@comment, i)
				}
			end
		end

		class ParamCommandComment < Comment
			def name
				Lib.extract_string Lib.param_command_comment_get_param_name(@comment)
			end

			def text
				self.map(&:text).join("")
			end

			alias_method :comment, :text

			def valid_index?
				Lib.param_command_comment_is_param_index_valid(@comment) != 0
			end

			def index
				Lib.param_command_comment_get_param_index(@comment)
			end

			def direction_explicit?
				Lib.param_command_comment_is_direction_explicit(@comment) != 0
			end

			def direction
				Lib.param_command_comment_get_direction(@comment)
			end
		end

		class TParamCommandComment < Comment
			def text
				self.child.text
			end
			alias_method :comment, :text

			def name
				Lib.extract_string Lib.tparam_command_comment_get_param_name(@comment)
			end

			def valid_position?
				Lib.tparam_command_comment_is_param_position_valid(@comment) != 0
			end

			def depth
				Lib.tparam_command_comment_get_depth(@comment)
			end

			def index(depth = 0)
				Lib.tparam_command_comment_get_index(@comment, depth)
			end
		end

		class VerbatimBlockCommandComment < Comment
			def text
				children.map(&:text).join("\n")
			end
		end

		class VerbatimBlockLineComment < Comment
			def text
				Lib.extract_string Lib.verbatim_block_line_comment_get_text(@comment)
			end
		end

		class VerbatimLine < Comment
			def text
				Lib.extract_string Lib.verbatim_line_comment_get_text(@comment)
			end
		end

		class FullComment < Comment
			def to_html
				Lib.extract_string Lib.full_comment_get_as_html(@comment)
			end

			def to_xml
				Lib.extract_string Lib.full_comment_get_as_xml(@comment)
			end
			
			def text
				self.children.collect{|child| child.text.strip}.join("\n")
			end
		end
	end
end
