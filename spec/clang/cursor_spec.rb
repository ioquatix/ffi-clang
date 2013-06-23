# Copyright, 2010-2012 by Jari Bakken.
# Copyright, 2013, by Samuel G. D. Williams. <http://www.codeotaku.com>
# Copyright, 2013, by Garry C. Marshall. <http://www.meaningfulname.net>
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

require 'spec_helper'

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

describe Cursor do
	let(:cursor) { Index.new.parse_translation_unit(fixture_path("list.c")).cursor }

	it "can be obtained from a translation unit" do
		cursor.should be_kind_of(Cursor)
		cursor.kind.should equal(:cursor_translation_unit)
	end

	it "returns the source location of the cursor" do
		location = cursor.location
		location.should be_kind_of(SourceLocation)
	end

	it "has an extent which is a SourceRange" do
		extent = cursor.extent
		extent.should be_kind_of(SourceRange)

		extent.start.file.should eq(fixture_path("list.c"))
		extent.start.line.should equal(1)

		extent.end.file.should eq(fixture_path("list.c"))
		extent.end.line.should equal(10)
	end

	it "returns the path of the translation unit for the translation unit cursor" do
		cursor.displayName.should eq(fixture_path("list.c"))
		cursor.spelling.should eq(fixture_path("list.c"))
	end

	it "allows us to visit its children" do
		counter = 0
		cursor.visit_children do |cursor, parent|
			counter += 1
			:recurse
		end
		counter.should_not equal(0)
	end

	describe "Function Cursors" do
		let (:func) { find_first(cursor, :cursor_function) }

		it "can find the first function declaration" do
			func.should_not equal(nil)
			func.kind.should equal(:cursor_function)
		end

		it "has an extent representing the bounds of the function" do
			func.extent.should be_kind_of(SourceRange)
			func.extent.start.line.should equal(5)
			func.extent.end.line.should equal(5)
		end

		it "returns the name of the function" do
			func.spelling.should eq("sum")
			func.displayName.should eq("sum(union List *)")
		end
	end

	describe "Struct Cursors" do
		let (:struct) { find_first(cursor, :cursor_struct) }

		it "can find the first struct" do
			struct.should_not equal(nil)
			struct.kind.should equal(:cursor_struct)
		end

		it "has an extent representing the bounds of the struct" do
			struct.extent.start.line.should equal(1)
			struct.extent.end.line.should equal(4)
		end

		it "returns the name of the struct" do
			struct.spelling.should eq("List")
			struct.displayName.should eq("List")
		end

	end
	
end
