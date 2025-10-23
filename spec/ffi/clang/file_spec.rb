# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2014-2025, by Samuel Williams.

describe File do
	let(:file_list) {Index.new.parse_translation_unit(fixture_path("list.c")).file(fixture_path("list.c"))}
	let(:file_docs) {Index.new.parse_translation_unit(fixture_path("docs.c")).file(fixture_path("docs.h"))}
	
	it "can be obtained from a translation unit" do
		expect(file_list).to be_kind_of(FFI::Clang::File)
	end
	
	describe "#name" do
		let(:name) {file_list.name}
		
		it "returns its file name" do
			expect(name).to be_kind_of(String)
			expect(name).to eq(fixture_path("list.c"))
		end
	end
	
	describe "#to_s" do
		let(:name) {file_list.to_s}
		
		it "returns its file name" do
			expect(name).to be_kind_of(String)
			expect(name).to eq(fixture_path("list.c"))
		end
	end
	
	describe "#time" do
		let(:time) {file_list.time}
		
		it "returns file time" do
			expect(time).to be_kind_of(Time)
		end
	end
	
	describe "#include_guarded?" do
		it "returns false if included file is notguarded" do
			expect(file_list.include_guarded?).to be false
		end
		
		it "returns true if included file is guarded" do
			expect(file_docs.include_guarded?).to be true
		end
	end
	
	describe "#device" do
		it "returns device from CXFileUniqueID" do
			expect(file_list.device).to be_kind_of(Integer)
		end
	end
	
	describe "#inode" do
		it "returns inode from CXFileUniqueID" do
			expect(file_list.inode).to be_kind_of(Integer)
		end
	end
	
	describe "#modification" do
		it "returns modification time as Time from CXFileUniqueID" do
			expect(file_list.modification).to be_kind_of(Time)
		end
	end
end
