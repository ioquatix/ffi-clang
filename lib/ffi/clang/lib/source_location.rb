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

require_relative 'file'

module FFI
	module Clang
		module Lib
			class CXSourceLocation < FFI::Struct
				layout(
					:ptr_data, [:pointer, 2],
					:int_data, :uint
				)
			end

			attach_function :get_null_location, :clang_getNullLocation, [], CXSourceLocation.by_value
			attach_function :equal_locations, :clang_equalLocations,  [CXSourceLocation.by_value, CXSourceLocation.by_value], :int

			attach_function :get_location, :clang_getLocation, [:CXTranslationUnit, :CXFile, :uint, :uint], CXSourceLocation.by_value
			attach_function :get_location_offset, :clang_getLocationForOffset, [:CXTranslationUnit, :CXFile, :uint], CXSourceLocation.by_value
			attach_function :get_expansion_location, :clang_getExpansionLocation, [CXSourceLocation.by_value, :pointer, :pointer, :pointer, :pointer], :void
			attach_function :get_presumed_location, :clang_getPresumedLocation, [CXSourceLocation.by_value, :pointer, :pointer, :pointer], :void
			if FFI::Clang::Utils.satisfy_version?('3.3')
				attach_function :get_file_location, :clang_getFileLocation, [CXSourceLocation.by_value, :pointer, :pointer, :pointer, :pointer], :void
			end
			attach_function :get_spelling_location, :clang_getSpellingLocation, [CXSourceLocation.by_value, :pointer, :pointer, :pointer, :pointer], :void

			if FFI::Clang::Utils.satisfy_version?('3.4')
				attach_function :location_in_system_header, :clang_Location_isInSystemHeader, [CXSourceLocation.by_value], :int
				attach_function :location_is_from_main_file, :clang_Location_isFromMainFile, [CXSourceLocation.by_value], :int
			end
		end
	end
end
