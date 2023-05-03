# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010, by Jari Bakken.
# Copyright, 2012, by Hal Brodigan.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2013, by Garry Marshall.
# Copyright, 2014, by Masahiro Sano.

require_relative 'lib/diagnostic'
require_relative 'source_range'

module FFI
	module Clang
		class Diagnostic < AutoPointer
			def self.default_display_opts
				Lib.opts_from(Lib::DiagnosticDisplayOptions, Lib.default_diagnostic_display_options)
			end

			def initialize(translation_unit, pointer)
				super pointer

				@translation_unit = translation_unit
			end

			def self.release(pointer)
				Lib.dispose_diagnostic(pointer)
			end

			def format(opts = {})
				cxstring = Lib.format_diagnostic(self, display_opts(opts))
				Lib.extract_string cxstring
			end

			def severity
				Lib.get_diagnostic_severity self
			end

			def spelling
				Lib.get_string Lib.get_diagnostic_spelling(self)
			end

			def location
				sl = Lib.get_diagnostic_location(self)
				ExpansionLocation.new sl
			end

			def fixits
				n = Lib.get_diagnostic_num_fix_its(self)
				n.times.map { |i|
				ptr = MemoryPointer.new Lib::CXSourceRange
					replace_text = Lib.extract_string(Lib.get_diagnostic_fix_it(self, i, ptr))
					{text: replace_text, range: SourceRange.new(ptr)}
				}
			end

			def ranges
				n = Lib.get_diagnostic_num_ranges(self)
				
				n.times.map {|i| SourceRange.new Lib.get_diagnostic_range(self, i)}
			end

			def children
				diagnostic_set = Lib.get_child_diagnostics(self)
				num_diagnostics = Lib.get_num_diagnostics_in_set(diagnostic_set)
				num_diagnostics.times.map { |i|
					Diagnostic.new(@translation_unit, Lib.get_diagnostic_in_set(diagnostic_set, i))
				}
			end

			def enable_option
				Lib.extract_string Lib.get_diagnostic_option(self, nil)
			end

			def disable_option
				ptr = MemoryPointer.new Lib::CXString
				Lib.get_diagnostic_option(self, ptr)
				Lib.extract_string ptr
			end

			def category
				Lib.extract_string Lib.get_diagnostic_category_text(self)
			end

			def category_id
				Lib.get_diagnostic_category(self)
			end

			def inspect
				"#{self.location}: #{self.format}"
			end

			private

			def display_opts(opts)
				if opts.empty?
					Lib.default_diagnostic_display_options
				else
					Lib.bitmask_from(Lib::DiagnosticDisplayOptions, opts)
				end
			end
		end
	end
end
