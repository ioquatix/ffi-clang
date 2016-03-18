# Copyright, 2010-2012 by Jari Bakken.
# Copyright, 2013, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require_relative 'string'
require_relative 'translation_unit'
require_relative 'version'

module FFI
	module Clang
		module Lib
			class CXUnsavedFile < FFI::Struct
				layout(
					:filename, :pointer,
					:contents, :pointer,
					:length, :ulong
				)
			end

			class CXFileUniqueID < FFI::Struct
				layout(
					:device, :ulong_long,
					:inode, :ulong_long,
					:modification, :ulong_long
				)
			end

			typedef :pointer, :CXFile

			attach_function :get_file, :clang_getFile, [:CXTranslationUnit, :string], :CXFile
			attach_function :get_file_name, :clang_getFileName, [:CXFile], CXString.by_value
			attach_function :get_file_time, :clang_getFileTime, [:CXFile], :time_t
			attach_function :is_file_multiple_include_guarded, :clang_isFileMultipleIncludeGuarded, [:CXTranslationUnit, :CXFile], :int
			if FFI::Clang::Utils.satisfy_version?('3.3')
				attach_function :get_file_unique_id, :clang_getFileUniqueID, [:CXFile, :pointer], :int
			end
		end
	end
end
