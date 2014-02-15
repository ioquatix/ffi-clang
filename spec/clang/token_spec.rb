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

require 'spec_helper'

describe Tokens do
	let(:tu) { Index.new.parse_translation_unit(fixture_path("list.c")) }
	let(:cursor) { tu.cursor }
	let(:range) { find_first(cursor, :cursor_struct).extent }
	let(:tokens) { tu.tokenize(range) }

	it "can be obtained from a translation unit" do
		expect(tokens).to be_kind_of(Tokens)
		expect(tokens.size).to eq(13)
		expect(tokens.tokens).to be_kind_of(Array)
		expect(tokens.tokens.first).to be_kind_of(Token)
	end

	it "calls dispose_tokens on GC" do
		expect(Lib).to receive(:dispose_tokens).at_least(:once)
		expect{tokens.free}.not_to raise_error
	end

	it "#each" do
		spy = double(stub: nil)
		expect(spy).to receive(:stub).exactly(tokens.size).times
		tokens.each { spy.stub }
	end

	it "#cursors" do
		expect(tokens.cursors).to be_kind_of(Array)
		expect(tokens.cursors.size).to eq(tokens.size)
		expect(tokens.cursors.first).to be_kind_of(Cursor)
	end
end

describe Token do
	let(:tu) { Index.new.parse_translation_unit(fixture_path("list.c")) }
	let(:cursor) { tu.cursor }
	let(:range) { find_first(cursor, :cursor_struct).extent }
	let(:token) { tu.tokenize(range).first }

	it "can be obtained from a translation unit" do
		expect(token).to be_kind_of(Token)
	end

	it "#kind" do
		expect(token.kind).to be_kind_of(Symbol)
		expect(token.kind).to eq(:keyword)
	end

	it "#spelling" do
		expect(token.spelling).to be_kind_of(String)
		expect(token.spelling).to eq('struct')
	end

	it "#location" do
		expect(token.location).to be_kind_of(SourceLocation)
		expect(token.location.line).to eq(1)
	end

	it "#extent" do
		expect(token.extent).to be_kind_of(SourceRange)
		expect(token.extent.start.line).to eq(1)
	end
end
