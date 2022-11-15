# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010, by Jari Bakken.
# Copyright, 2012, by Hal Brodigan.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2013, by Garry Marshall.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2014, by Greg Hazel.
# Copyright, 2019, by Michael Metivier.
# Copyright, 2022, by Motonori Iwamuro.

require_relative 'lib/translation_unit'
require_relative 'lib/inclusions'
require_relative 'cursor'
require_relative 'file'
require_relative 'token'

module FFI
	module Clang
		class TranslationUnit < AutoPointer
			def initialize(pointer, index)
				super pointer
				@index = index
			end

			def self.release(pointer)
				Lib.dispose_translation_unit(pointer)
			end

			def self.default_editing_translation_unit_options
				bitmask = Lib.default_editing_translation_unit_options
				Lib.opts_from Lib::TranslationUnitFlags, bitmask
			end

			def default_save_options
				bitmask = Lib.default_save_options(self)
				Lib.opts_from Lib::SaveTranslationUnitFlags, bitmask
			end

			def save(filename, opts = {})
				ret = Lib.save_translation_unit(self, filename, 0)
				sym = Lib::SaveError[ret]
				raise Error, "unknown return values: #{ret} #{sym.inspect}" unless sym
				raise Error, "save error: #{sym.inspect}, filename: #{filename}" if sym != :none
			end

			def default_reparse_options
				bitmask = Lib.default_save_options(self)
				Lib.opts_from Lib::ReparseFlags, bitmask
			end

			def reparse(unsaved = [], opts = {})
				unsaved_files = UnsavedFile.unsaved_pointer_from(unsaved)
				if Lib.reparse_translation_unit(self, unsaved.size, unsaved_files, 0) != 0
					raise Error, "reparse error"
				end
			end

			def diagnostics
				n = Lib.get_num_diagnostics(self)
			
				n.times.map do |i|
					Diagnostic.new(self, Lib.get_diagnostic(self, i))
				end
			end

			def cursor(location = nil)
				if location.nil?
					Cursor.new Lib.get_translation_unit_cursor(self), self
				else
					Cursor.new Lib.get_cursor(self, location.location), self
				end
			end

			def location(file, line, column)
				ExpansionLocation.new Lib.get_location(self, file, line, column)
			end

			def location_offset(file, offset)
				ExpansionLocation.new Lib.get_location_offset(self, file, offset)
			end

			def file(file_name = nil)
				if file_name.nil?
					File.new(Lib.get_file(self, spelling), self)
				else
					File.new(Lib.get_file(self, file_name), self)
				end
			end

			def spelling
				Lib.extract_string Lib.get_translation_unit_spelling(self)
			end

			def resource_usage
				FFI::Clang::TranslationUnit::ResourceUsage.new Lib.resource_usage(self)
			end

			def tokenize(range)
				token_ptr = MemoryPointer.new :pointer
				uint_ptr = MemoryPointer.new :uint
				Lib.tokenize(self, range.range, token_ptr, uint_ptr)
				Tokens.new(token_ptr.get_pointer(0), uint_ptr.get_uint(0), self)
			end

			def code_complete(source_file, line, column, unsaved = [], opts = nil)
				opts = CodeCompletion.default_code_completion_options if opts.nil?
				unsaved_files = UnsavedFile.unsaved_pointer_from(unsaved)
				option_bitmask = Lib.bitmask_from(Lib::CodeCompleteFlags, opts)
				ptr = Lib.code_complete_at(self, source_file, line, column, unsaved_files, unsaved.length, option_bitmask)
				CodeCompletion::Results.new ptr, self
			end

			def inclusions(&block)
				adapter = Proc.new do |included_file, inclusion_stack, include_len, unused|
					file = Lib.extract_string Lib.get_file_name(included_file)
					cur_ptr = inclusion_stack
					inclusions = []
					include_len.times {
						inclusions << SourceLocation.new(Lib::CXSourceLocation.new(cur_ptr))
						cur_ptr += Lib::CXSourceLocation.size
					}
					block.call file, inclusions
				end
				
				Lib.get_inclusions(self, adapter, nil)
			end

			class ResourceUsage < AutoPointer
				def initialize(resource_usage)
					# CXResourceUsage is returned by value and should be freed explicitly.
					# Get FFI::pointer of the data so that the data is handled by AutoPointer.
					pointer = FFI::Pointer.new(resource_usage.to_ptr)
					super(pointer)
					@resource_usage = resource_usage
				end

				def self.release(pointer)
					# clang_disposeCXTUResourceUsage requires value type, so create it by pointer
					Lib.dispose_resource_usage(Lib::CXTUResourceUsage.new(pointer))
				end

				def self.name(kind)
					Lib.resource_usage_name(kind)
				end

				def entries
					ary = []
					ptr = @resource_usage[:entries]
					@resource_usage[:numEntries].times {
						ary << Lib::CXTUResourceUsageEntry.new(ptr)
						ptr += Lib::CXTUResourceUsageEntry.size
					}
					ary
				end
			end
		end
	end
end
