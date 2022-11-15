# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2014-2022, by Samuel Williams.

require 'ffi/clang/version'

describe FFI::Clang.clang_version_string do
	it "returns a version string for showing to user" do
		expect(subject).to be_kind_of(String)
		expect(subject).to match(/Apple LLVM version \d+\.\d+\.\d+|clang version \d+\.\d+/)
	end
end
