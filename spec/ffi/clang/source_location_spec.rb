# Copyright, 2010-2012 by Jari Bakken.
# Copyright, 2013, by Samuel G. D. Williams. <http://www.codeotaku.com>
# Copyright, 2013, by Garry C. Marshall. <http://www.meaningfulname.net>
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

require_relative 'spec_helper'

describe SourceLocation do
	let(:translation_unit)                   { Index.new.parse_translation_unit(fixture_path("list.c")) }
	let(:translation_unit_location)          { translation_unit.cursor.location }
	let(:diagnostic_location)  { translation_unit.diagnostics.first.location }
	let(:loc1_translation_unit)              { Index.new.parse_translation_unit(fixture_path("location1.c")) }
	let(:loc1_cursor)          { find_first(loc1_translation_unit.cursor, :cursor_function) }
	let(:docs_cursor)          { Index.new.parse_translation_unit(fixture_path("docs.c")).cursor }

	it "should have a nil File if the SourceLocation is for a Translation Unit" do
		expect(translation_unit_location.file).to be_nil
	end

	it "should provide a File, line and column for a Diagnostic" do
		expect(diagnostic_location.file).to eq(fixture_path("list.c"))
		expect(diagnostic_location.line).to equal(5)
		expect(diagnostic_location.column).to equal(9)
	end

	it "should be ExpansionLocation" do
		expect(translation_unit_location).to be_kind_of(SourceLocation)
		expect(translation_unit_location).to be_kind_of(ExpansionLocation)
	end

	describe "Null Location" do
		let(:null_location) { SourceLocation.null_location }
		it "can be a null location" do
			expect(null_location).to be_kind_of(SourceLocation)
			expect(null_location.file).to be_nil
			expect(null_location.line).to eq(0)
			expect(null_location.column).to eq(0)
			expect(null_location.offset).to eq(0)
		end

		it "is null?" do
			expect(null_location.null?).to equal(true)
		end

		it "compares as equal to another null location instance" do
			expect(null_location).to eq(SourceLocation.null_location)
		end
	end

	describe "#from_main_file?", from_3_4: true do
		it "returns true if the cursor location is in main file" do
			expect(loc1_cursor.location.from_main_file?).to be true
		end

		it "returns false if the cursor location is not in main file" do
			expect(docs_cursor.location.from_main_file?).to be false
		end
	end

	describe "#in_system_header?", from_3_4: true do
		it "returns false if the cursor location is not in system header" do
			expect(loc1_cursor.location.in_system_header?).to be false
		end
	end

	describe "#expansion_location" do
		let (:expansion_location) { loc1_cursor.location.expansion_location }

		it "should be ExpansionLocaion" do
			expect(expansion_location).to be_kind_of(SourceLocation)
			expect(expansion_location).to be_kind_of(ExpansionLocation)
		end

		it "returns source location that does not care a # line directive" do
			expect(expansion_location.line).to eq(3)
		end
	end

	describe "#presumed_location" do
		let (:presumed_location) { loc1_cursor.location.presumed_location }

		it "should be FileLocaion" do
			expect(presumed_location).to be_kind_of(SourceLocation)
			expect(presumed_location).to be_kind_of(PresumedLocation)
		end

		it "returns preprocessed filename" do
			expect(presumed_location.filename).to eq("dummy.c")
		end

		it "returns source location specified by a # line directive" do
			expect(presumed_location.line).to eq(124)
		end
	end

	describe "#file_location", from_3_3: true do
		let (:file_location) { loc1_cursor.location.file_location }

		it "should be FileLocaion" do
			expect(file_location).to be_kind_of(SourceLocation)
			expect(file_location).to be_kind_of(FileLocation)
		end

		it "returns source location that does not care a # line directive" do
			expect(file_location.line).to eq(3)
		end
	end

	describe "#spelling_location" do
		let (:spelling_location) { loc1_cursor.location.spelling_location }

		it "should be SpellingLocaion" do
			expect(spelling_location).to be_kind_of(SourceLocation)
			expect(spelling_location).to be_kind_of(SpellingLocation)
		end

		it "returns source location that does not care a # line directive" do
			expect(spelling_location.line).to eq(3)
		end
	end

end
