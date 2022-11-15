# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2014-2022, by Samuel Williams.

require_relative 'lib/compilation_database'

module FFI
	module Clang
		class CompilationDatabase < AutoPointer
			class DatabaseLoadError < FFI::Clang::Error; end

			def initialize(dirpath)
				uint_ptr = MemoryPointer.new :uint
				cdb_ptr = Lib.compilation_database_from_directory(dirpath, uint_ptr)
				error_code = Lib::CompilationDatabaseError[uint_ptr.read_uint]
				if error_code != :no_error
					raise DatabaseLoadError, "Cannot load database: #{error_code}"
				end
				super cdb_ptr
			end

			def self.release(pointer)
				Lib.compilation_database_dispose(pointer)
			end

			def compile_commands(filename)
				CompileCommands.new Lib.compilation_database_get_compile_commands(self, filename), self
			end

			def all_compile_commands
				CompileCommands.new Lib.compilation_database_get_all_compile_commands(self), self
			end

			class CompileCommands < AutoPointer
				include Enumerable

				def initialize(pointer, database)
					super pointer
					@database = database
				end

				def self.release(pointer)
					Lib.compile_commands_dispose(pointer)
				end

				def size
					Lib.compile_commands_get_size(self)
				end

				def command(i)
					CompileCommand.new Lib.compile_commands_get_command(self, i)
				end

				def commands
					size.times.map { |i| command(i) }
				end

				def each(&block)
					size.times.map do |i|
						block.call(command(i))
					end
				end
			end

			class CompileCommand
				def initialize(pointer)
					@pointer = pointer
				end

				def directory
					Lib.extract_string Lib.compile_command_get_directory(@pointer)
				end

				def num_args
					Lib.compile_command_get_num_args(@pointer)
				end

				def arg(i)
					Lib.extract_string Lib.compile_command_get_arg(@pointer, i)
				end

				def args
					num_args.times.map { |i| arg(i) }
				end

				def num_mapped_sources
					raise NotImplementedError
					# Lib.compile_command_get_num_mapped_sources(@pointer)
				end

				def mapped_source_path(i)
					raise NotImplementedError
					# Lib.extract_string Lib.compile_command_get_mapped_source_path(@pointer, i)
				end

				def mapped_source_content(i)
					raise NotImplementedError
					# Lib.extract_string Lib.compile_command_get_mapped_source_content(@pointer, i)
				end

				def mapped_sources
					num_mapped_sources.times.map { |i|
						{path: mapped_source_path(i), content: mapped_source_content(i)}
					}
				end
			end
		end
	end
end
