# -*- coding: utf-8 -*-

# Released under the MIT License.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2014, by Masahiro Sano.

# Released under the MIT License.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2013-2014, by Samuel Williams.
# Copyright, 2014, by Masahiro Sano.

module FFI
	module Clang
		class UnsavedFile
			def initialize(filename, contents)
				@filename = filename
				@contents = contents
			end

			attr_accessor :filename, :contents


			def self.unsaved_pointer_from(unsaved)
				return nil if unsaved.length == 0

				vec = MemoryPointer.new(Lib::CXUnsavedFile, unsaved.length)

				unsaved.each_with_index do |file, i|
					uf = Lib::CXUnsavedFile.new(vec + i * Lib::CXUnsavedFile.size)
					uf[:filename] = MemoryPointer.from_string(file.filename)
					uf[:contents] = MemoryPointer.from_string(file.contents)
					uf[:length] = file.contents.length
				end

				vec
			end
		end
	end
end
