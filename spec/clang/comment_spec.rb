# -*- coding: utf-8 -*-
# Copyright, 2013, by Carlos Martín Nieto <cmn@dwim.me>
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

describe Comment do
	let(:cursor) { Index.new.parse_translation_unit(fixture_path("docs.h")).cursor }
	let (:comment) { find_first(cursor, :cursor_function).comment }

	it "can be obtained from a cursor" do
		comment.should be_kind_of(Comment)
		comment.should be_kind_of(FullComment)
		comment.kind.should equal(:comment_full)
	end

	it "can parse the brief description" do
		para = comment.child
		para.kind.should equal(:comment_paragraph)
		para.should be_kind_of(ParagraphComment)
		text = para.child
		text.kind.should equal(:comment_text)
		text.should be_kind_of(TextComment)
		text.text.strip.should eq("Short explanation")
	end

	it "can parse the longer description" do
		para = comment.child(1)
		para.kind.should equal(:comment_paragraph)
		para.num_children.should equal(2)
		text = para.child

		lines = (0..para.num_children-1).map do |i|
			para.child(i).text
		end

		lines.should eq([" This is a longer explanation",
				 " that spans multiple lines"])
	end

	it "has working helpers" do
		comment.num_children.should equal(6)

		para = comment.child(1)
		para.text.should eq(" This is a longer explanation\n that spans multiple lines")
	end

	it "understands params" do
		[['input', " some input\n "], ['flags', " some flags\n "]].each_with_index do |v, child_idx|
			param = comment.child(3 + child_idx)
			param.should be_kind_of(ParamCommandComment)

			param.valid_index?.should == true
			param.index.should equal(child_idx)
			param.name.should eq(v[0])
			param.child.text.should eq v[1]
			param.comment.should eq v[1]
		end
	end

	describe "#whitespace?" do
		it "checks the comment is whitespace" do
			expect(comment.child.whitespace?).to be_false
		end
	end

	describe "#has_trailing_newline?" do
		it "checks the content has a traling newline" do
			expect(comment.child.has_trailing_newline?).to be_false
		end
	end

	context 'comment_null' do
		let(:comment_cursor) { find_matching(cursor) { |child, parent|
				child.kind == :cursor_function and child.spelling == 'no_comment_function' } }
		let(:comment) { comment_cursor.comment }

		it "is null comment" do
			expect(comment).to be_kind_of(Comment)
			expect(comment.kind).to eq(:comment_null)
			expect(comment.text).to eq('')
		end
	end

	context 'unknown comment type' do
		let(:comment) { 'foobar' }
		it "raises NotImplementedError" do
			expect(Lib).to receive(:comment_get_kind).with(comment).and_return(:xxx_yyy_zzzz)
			expect{Comment.build_from(comment)}.to raise_error(NotImplementedError)
		end
	end
end
