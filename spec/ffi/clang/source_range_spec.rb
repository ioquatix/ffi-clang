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

describe SourceRange do
	let(:tu) { Index.new.parse_translation_unit(fixture_path("list.c")) }
	let(:tu_range) { tu.cursor.extent }

	it "can be obtained from a cursor" do
		expect(tu_range).to be_kind_of(SourceRange)
		expect(tu_range.null?).to be false
	end

	it "has start and end source location" do
		expect(tu_range.start).to be_kind_of(SourceLocation)
		expect(tu_range.start.null?).to be false
		expect(tu_range.end).to be_kind_of(SourceLocation)
		expect(tu_range.end.null?).to be false
	end

	describe "Null Range" do
		let(:null_range) { SourceRange.null_range }
		it "can be a null range" do
			expect(null_range).to be_kind_of(SourceRange)
		end

		it "is null?" do
			expect(null_range.null?).to equal(true)
		end

		it "has null locations" do
		    expect(null_range.start.null?).to be true
		    expect(null_range.end.null?).to be true
		end

		it "compares as equal to another null range instance" do
			expect(null_range).to eq(SourceRange.null_range)
		end
	end

    describe "Get Range" do
        let(:range) { SourceRange.new(tu_range.start, tu_range.end) }

        it "can be obtained from two source locations" do
			expect(range).to be_kind_of(SourceRange)
			expect(range.null?).to be false
        end

        it "is same to original source range" do
			expect(range).to eq(tu_range)
        end

        it "is same to original source range's locations" do
			expect(range.start).to eq(tu_range.start)
			expect(range.end).to eq(tu_range.end)
        end
    end
end
