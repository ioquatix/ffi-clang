# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010, by Jari Bakken.
# Copyright, 2012, by Hal Brodigan.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2019, by Hayden Purdy.

describe Index do
	before :all do
		FileUtils.mkdir_p TMP_DIR
	end

	after :all do
		# FileUtils.rm_rf TMP_DIR
	end

	let(:index) { Index.new }

	it "calls dispose_index on GC" do
		index.autorelease = false
		# It's possible for this to be called multiple times if there are other Index instances created during test
		# expect(Lib).to receive(:dispose_index).with(index).once
		expect{index.free}.not_to raise_error
	end

	describe '#parse_translation_unit' do
		it "can parse a source file" do
			translation_unit = index.parse_translation_unit fixture_path("a.c")
			expect(translation_unit).to be_kind_of(TranslationUnit)
		end

		it "raises error when file is not found" do
			expect { index.parse_translation_unit fixture_path("xxxxxxxxx.c") }.to raise_error(FFI::Clang::Error)
		end

		it "can handle command line options" do
			index.parse_translation_unit(fixture_path("a.c"), ["-std=c99"])
		end

		it 'can handle translation unit options' do 
			expect{index.parse_translation_unit(fixture_path("a.c"), [], [], [:incomplete, :single_file_parse, :cache_completion_results])}.not_to raise_error
		end

		it 'can handle missing translation options' do 
			expect{index.parse_translation_unit(fixture_path("a.c"), [], [], [])}.not_to raise_error
		end

		it 'can handle translation options with random values' do 
			expect{index.parse_translation_unit(fixture_path("a.c"), [], [], {:incomplete => 654, :single_file_parse => 8, :cache_completion_results => 93})}.not_to raise_error
		end

		it "raises error when one of the translation options is invalid" do
			expect{index.parse_translation_unit(fixture_path("a.c"), [], [], [:incomplete, :random_option, :cache_completion_results])}.to raise_error(FFI::Clang::Error)
		end
	end

	describe '#create_translation_unit' do
		let(:simple_ast_path) {"#{TMP_DIR}/simple.ast"}
		
		before :each do
			translation_unit = index.parse_translation_unit fixture_path("simple.c")
			
			translation_unit.save(simple_ast_path)
		end

		it "can create translation unit from a ast file" do
			expect(FileTest.exist?("#{TMP_DIR}/simple.ast")).to be true
			translation_unit = index.create_translation_unit "#{TMP_DIR}/simple.ast"
			expect(translation_unit).to be_kind_of(TranslationUnit)
		end

		it "raises error when file is not found" do
			expect(FileTest.exist?('not_found.ast')).to be false
			expect { index.create_translation_unit 'not_found.ast' }.to raise_error(FFI::Clang::Error)
		end
	end
end
