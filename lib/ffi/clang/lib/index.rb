# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010, by Jari Bakken.
# Copyright, 2012, by Hal Brodigan.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2024, by Charlie Savage.

module FFI
	module Clang
		module Lib
			typedef :pointer, :CXIndex

			# Source code index:
			attach_function :create_index, :clang_createIndex, [:int, :int], :CXIndex
			attach_function :dispose_index, :clang_disposeIndex, [:CXIndex], :void

			if Clang.clang_version >= Gem::Version.new('17.0.0')
				class CXIndexOptions < FFI::Struct
					layout(
						:size, :uint,
						:thread_background_priority_for_indexing, :uchar,
						:thread_background_priority_for_editing, :uchar,
						:exclude_declarations_from_pch, :uint,
						:display_diagnostics, :uint,
						:store_preambles_in_memory, :uint,
						:reserved, :uint,
						:preamble_storage_path, :string,
						:invocation_emission_path, :string
					)
				end

				attach_function :create_index_with_options, :clang_createIndexWithOptions, [CXIndexOptions.by_ref], :CXIndex
			end
		end
	end
end
