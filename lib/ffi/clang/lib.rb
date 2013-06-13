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

module FFI
	module Clang
		module Lib
			extend FFI::Library

			libs = ["clang"]

			if Clang.platform == :linux
				libs += [
					"/usr/lib/llvm-3.2/lib/libclang.so",
					"/usr/lib64/llvm-3.2/lib/libclang.so"
				]
			end

			ffi_lib libs


			TranslationUnitFlags     = enum [:none, :detailed_preprocessing_record, :incomplete, :precompiled_preamble, :cache_completion_results]
			DiagnosticDisplayOptions = enum [:source_location, 0x01,
				:column,          0x02,
				:source_ranges,   0x04]

				enum :diagnostic_severity, [:ignored, :note, :warning, :error, :fatal]

				attach_function :create_index,                       :clang_createIndex,                     [:int,      :int],     :pointer
				attach_function :dispose_index,                      :clang_disposeIndex,                    [:pointer], :void
				def self.dispose_index_debug(*args)
					puts "dispose index: #{args.inspect}"
					self.dispose_index(*args)
				end
				attach_function :parse_translation_unit,             :clang_parseTranslationUnit,            [:pointer,  :string,   :pointer, :int, :pointer, :uint, :uint], :pointer
				attach_function :dispose_translation_unit,           :clang_disposeTranslationUnit,          [:pointer], :void
				def self.dispose_translation_unit_debug(*args)
					puts "dispose translation unit: #{args.inspect}"
					self.dispose_translation_unit(*args)
				end
				attach_function :get_num_diagnostics,                :clang_getNumDiagnostics,               [:pointer], :uint
				attach_function :get_diagnostic,                     :clang_getDiagnostic,                   [:pointer,  :uint],    :pointer
				attach_function :dispose_diagnostic,                 :clang_disposeDiagnostic,               [:pointer], :void
				def self.dispose_diagnostic_debug(*args)
					puts "dispose diagnostic: #{args.inspect}"
					self.dispose_diagnostic(*args)
				end
				attach_function :format_diagnostic,                  :clang_formatDiagnostic,                [:pointer,  :uint],    :pointer
				attach_function :default_diagnostic_display_options, :clang_defaultDiagnosticDisplayOptions, [],         :uint
				attach_function :get_c_string,                       :clang_getCString,                      [:pointer], :string
				attach_function :dispose_string,                     :clang_disposeString,                   [:pointer], :void
				attach_function :get_diagnostic_location,            :clang_getDiagnosticLocation,           [:pointer], :pointer
				attach_function :get_diagnostic_spelling,            :clang_getDiagnosticSpelling,           [:pointer], :pointer
				attach_function :get_diagnostic_severity,            :clang_getDiagnosticSeverity,           [:pointer], :diagnostic_severity
				attach_function :get_diagnostic_num_ranges,          :clang_getDiagnosticNumRanges,          [:pointer], :uint
				attach_function :get_diagnostic_range,               :clang_getDiagnosticRange,              [:pointer,  :uint],    :pointer
				attach_function :equal_locations,                    :clang_equalLocations,                  [:pointer,  :pointer], :uint

				def self.extract_string(cxstring)
					result = get_c_string(cxstring)

					dispose_string cxstring
					result
				end

				def self.bitmask_from(enum, opts)
					bitmask = 0

					opts.each do |key, val|
						next unless val

						if int = enum[key]
							bitmask |= int
						else
							raise Error, "unknown option: #{key.inspect}, expected one of #{enum.symbols}"
						end
					end

					bitmask
				end
			end
		end
	end
