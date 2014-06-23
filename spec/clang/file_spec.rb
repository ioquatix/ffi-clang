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

describe File do
	let(:file_list) { Index.new.parse_translation_unit(fixture_path("list.c")).file(fixture_path("list.c")) }
	let(:file_docs) { Index.new.parse_translation_unit(fixture_path("docs.c")).file(fixture_path("docs.h")) }

	it "can be obtained from a translation unit" do
		expect(file_list).to be_kind_of(FFI::Clang::File)
	end

	describe "#name" do
		let(:name) { file_list.name }

		it 'returns its file name' do
			expect(name).to be_kind_of(String)
			expect(name).to eq(fixture_path("list.c"))
		end
	end

	describe "#to_s" do
		let(:name) { file_list.to_s }

		it 'returns its file name' do
			expect(name).to be_kind_of(String)
			expect(name).to eq(fixture_path("list.c"))
		end
	end

	describe "#time" do
		let(:time) { file_list.time }

		it 'returns file time' do
			expect(time).to be_kind_of(Time)
		end
	end

	describe "#include_guarded?" do
		it 'returns false if included file is notguarded' do
			expect(file_list.include_guarded?).to be false
		end

		it 'returns true if included file is guarded' do
			expect(file_docs.include_guarded?).to be true
		end
	end

	describe "#device", from_3_3: true do
		it 'returns device from CXFileUniqueID' do
			expect(file_list.device).to be_kind_of(Integer)
		end
	end

	describe "#inode", from_3_3: true do
		it 'returns inode from CXFileUniqueID' do
			expect(file_list.inode).to be_kind_of(Integer)
		end
	end

	describe "#modification", from_3_3: true do
		it 'returns modification time as Time from CXFileUniqueID' do
			expect(file_list.modification).to be_kind_of(Time)
		end
	end
end
