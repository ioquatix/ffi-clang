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
		param = comment.child(3)
		param.should be_kind_of(ParamCommandComment)

		param.valid_index?.should == true
		param.index.should equal(0)
		param.name.should eq("input")
		arg = " some input\n "
		param.child.text.should eq(arg)
		param.comment.should eq(arg)
	end

	it "understands blocks" do
		block = comment.child(5)
		block.should be_kind_of(BlockCommandComment)
		block.name.should eq("return")
		block.comment.should eq(" a random value\n ")
	end

end
