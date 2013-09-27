$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'ffi/clang'

include FFI::Clang

module ClangSpecHelper
	def fixture_path(path)
		File.join File.expand_path("../fixtures", __FILE__), path
	end

	def find_first(cursor, kind)
		first = nil

		cursor.visit_children do |cursor, parent|
			if (cursor.kind == kind)
				first = cursor
				:break
			else
				:recurse
			end
		end

		first
	end

  def find_matching(cursor, &term)
    ret = nil

    cursor.visit_children do |child, parent|
      if term.call child, parent
        ret = child
        next :break
      end

      :recurse
    end

    ret
  end
end

RSpec.configure do |c|
	c.include ClangSpecHelper
end
