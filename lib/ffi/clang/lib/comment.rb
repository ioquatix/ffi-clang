# Copyright, 2010-2012 by Jari Bakken.
# Copyright, 2013, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'ffi/clang/lib/index'

module FFI
	module Clang
		module Lib
			class CXComment < FFI::Struct
				layout(
				       :ast_node, :pointer,
				       :translation_unit, :pointer
				       )
			end

			enum :kind, [:comment_null, 0,
				     :comment_text, 1,
				     :comment_inline_command, 2,
				     :comment_paragraph, 5,
				     :comment_block_command,6 ,
				     :comment_param_command, 7,
				     :comment_full, 12]

			attach_function :comment_get_kind, :clang_Comment_getKind, [CXComment.by_value], :kind
			attach_function :comment_get_num_children, :clang_Comment_getNumChildren, [CXComment.by_value], :uint
			attach_function :comment_get_child, :clang_Comment_getChild, [CXComment.by_value, :uint], CXComment.by_value
			attach_function :text_comment_get_text, :clang_TextComment_getText, [CXComment.by_value], CXString.by_value
			attach_function :block_command_comment_get_paragraph, :clang_BlockCommandComment_getParagraph, [CXComment.by_value], CXComment.by_value
			attach_function :full_comment_get_as_html, :clang_FullComment_getAsHTML, [CXComment.by_value], CXString.by_value
			attach_function :full_comment_get_as_xml, :clang_FullComment_getAsXML, [CXComment.by_value], CXString.by_value

			attach_function :param_command_comment_get_param_name, :clang_ParamCommandComment_getParamName, [CXComment.by_value], CXString.by_value
			attach_function :param_command_comment_is_param_index_valid, :clang_ParamCommandComment_isParamIndexValid, [CXComment.by_value], :uint
			attach_function :param_command_comment_get_param_index, :clang_ParamCommandComment_getParamIndex, [CXComment.by_value], :uint
			attach_function :block_command_comment_get_command_name, :clang_BlockCommandComment_getCommandName, [CXComment.by_value], CXString.by_value
			attach_function :block_command_comment_get_num_args, :clang_BlockCommandComment_getNumArgs, [CXComment.by_value], :uint
			attach_function :inline_command_comment_get_command_name, :clang_InlineCommandComment_getCommandName, [CXComment.by_value], CXString.by_value
			attach_function :inline_command_comment_get_num_args, :clang_InlineCommandComment_getNumArgs, [CXComment.by_value], :uint
		end
	end
end
