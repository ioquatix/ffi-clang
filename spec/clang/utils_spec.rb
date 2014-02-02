# Copyright, 2014 by Masahiro Sano.
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

describe FFI::Clang::Utils do
	describe '#self.clang_version_string' do
		let (:version) { Utils::clang_version_string }
		it "returns a version string for showing to user" do
			expect(version).to be_kind_of(String)
			expect(version).to match(/clang version \d+\.\d+/)
		end
	end

	describe '#self.self.clang_version' do
		let (:version) { Utils::clang_version }
		it "returns only a version of clang as string" do
			expect(version).to be_kind_of(String)
			expect(version).to match(/^\d+\.\d+$/)
		end
	end

	describe '#self.clang_version_symbol' do
		let (:symbol) { Utils::clang_version_symbol }
		it "returns a symbol that represents clang version" do
			expect(symbol).to be_kind_of(Symbol)
			expect(symbol.to_s).to match(/^clang_\d+\_\d+$/)
		end
	end

	describe '#self.self.clang_major_version' do
		let (:version) { Utils::clang_major_version }
		it "returns major versions as integer" do
			expect(version).to be_kind_of(Integer)
		end
	end

	describe '#self.self.clang_minor_version' do
		let (:version) { Utils::clang_minor_version }
		it "returns minor versions as integer" do
			expect(version).to be_kind_of(Integer)
		end
	end
end
