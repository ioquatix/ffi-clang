# Copyright, 2014, by Masahiro Sano.
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

module FFI
	module Clang
		module Lib
			class CXToken < FFI::Struct
				layout(
					:int_data, [:uint, 4],
					:ptr_data, :pointer,
				)
			end

			class TokensPointer < FFI::Pointer
				attr_reader :token_size
				attr_reader :translation_unit
				def initialize(ptr, token_size, translation_unit)
					super ptr
					@token_size = token_size
					@translation_unit = translation_unit
				end
			end

			enum :token_kind, [
				:punctuation,
				:keyword,
				:identifier,
				:literal,
				:comment,
			]

			attach_function :get_token_kind, :clang_getTokenKind, [CXToken.by_value], :token_kind
			attach_function :get_token_spelliing, :clang_getTokenSpelling, [:CXTranslationUnit, CXToken.by_value], CXString.by_value
			attach_function :get_token_location, :clang_getTokenLocation, [:CXTranslationUnit, CXToken.by_value], CXSourceLocation.by_value
			attach_function :get_token_extent, :clang_getTokenExtent, [:CXTranslationUnit, CXToken.by_value], CXSourceRange.by_value
			attach_function :tokenize, :clang_tokenize, [:CXTranslationUnit, CXSourceRange.by_value, :pointer, :pointer], :void
			attach_function :annotate_tokens, :clang_annotateTokens, [:CXTranslationUnit, :pointer, :uint, :pointer], :void
			attach_function :dispose_tokens, :clang_disposeTokens, [:CXTranslationUnit, :pointer, :uint], :void
		end
	end
end
