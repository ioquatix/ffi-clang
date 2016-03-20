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
			typedef :pointer, :CXCompilationDatabase
			typedef :pointer, :CXCompileCommands
			typedef :pointer, :CXCompileCommand

			CompilationDatabaseError = enum [
				:no_error, 0,
				:can_not_load_database, 1,
			]

			# CompilationDatabase
			attach_function :compilation_database_from_directory, :clang_CompilationDatabase_fromDirectory, [:string, :pointer], :CXCompilationDatabase
			attach_function :compilation_database_dispose, :clang_CompilationDatabase_dispose, [:CXCompilationDatabase], :uint
			attach_function :compilation_database_get_compile_commands, :clang_CompilationDatabase_getCompileCommands, [:CXCompilationDatabase, :string], :CXCompileCommands
			attach_function :compilation_database_get_all_compile_commands, :clang_CompilationDatabase_getAllCompileCommands, [:CXCompilationDatabase], :CXCompileCommands

			# CompilationDatabase::CompileCommands
			attach_function :compile_commands_dispose, :clang_CompileCommands_dispose, [:CXCompileCommands], :void
			attach_function :compile_commands_get_size, :clang_CompileCommands_getSize, [:CXCompileCommands], :uint
			attach_function :compile_commands_get_command, :clang_CompileCommands_getCommand, [:CXCompileCommands, :uint], :CXCompileCommand

			# CompilationDatabase::CompileCommand
			attach_function :compile_command_get_directory, :clang_CompileCommand_getDirectory, [:CXCompileCommand], CXString.by_value
			attach_function :compile_command_get_num_args, :clang_CompileCommand_getNumArgs, [:CXCompileCommand], :uint
			attach_function :compile_command_get_arg, :clang_CompileCommand_getArg, [:CXCompileCommand, :uint], CXString.by_value
			
			# Thease functions are not exposed by libclang.so privided by packages.
			# attach_function :compile_command_get_num_mapped_sources, :clang_CompileCommand_getNumMappedSources, [:CXCompileCommand], :uint
			# attach_function :compile_command_get_mapped_source_path, :clang_CompileCommand_getMappedSourcePath, [:CXCompileCommand, :uint], CXString.by_value
			# attach_function :compile_command_get_mapped_source_content, :clang_CompileCommand_getMappedSourceContent, [:CXCompileCommand, :uint], CXString.by_value
		end
	end
end
