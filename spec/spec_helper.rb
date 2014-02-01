$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'ffi/clang'

include FFI::Clang

module ClangSpecHelper
	def fixture_path(path)
		File.join File.expand_path("../fixtures", __FILE__), path
	end

	def find_all(cursor, kind)
		ret = []

		cursor.visit_children do |cursor, parent|
			if (cursor.kind == kind)
				ret << cursor
			end
			:recurse
		end

		ret
	end

	def find_first(cursor, kind)
		find_all(cursor, kind).first
	end

	def find_all_matching(cursor, &term)
		ret = []

		cursor.visit_children do |child, parent|
			if term.call child, parent
				ret << child
			end

			:recurse
		end

		ret
	end

	def find_matching(cursor, &term)
		find_all_matching(cursor, &term).first
	end
end

RSpec.configure do |c|
	c.include ClangSpecHelper
end
