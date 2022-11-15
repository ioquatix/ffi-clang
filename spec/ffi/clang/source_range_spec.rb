# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2014-2022, by Samuel Williams.

describe SourceRange do
	let(:translation_unit) { Index.new.parse_translation_unit(fixture_path("list.c")) }
	let(:translation_unit_range) { translation_unit.cursor.extent }

	it "can be obtained from a cursor" do
		expect(translation_unit_range).to be_kind_of(SourceRange)
		expect(translation_unit_range.null?).to be false
	end

	it "has start and end source location" do
		expect(translation_unit_range.start).to be_kind_of(SourceLocation)
		expect(translation_unit_range.start.null?).to be false
		expect(translation_unit_range.end).to be_kind_of(SourceLocation)
		expect(translation_unit_range.end.null?).to be false
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
        let(:range) { SourceRange.new(translation_unit_range.start, translation_unit_range.end) }

        it "can be obtained from two source locations" do
			expect(range).to be_kind_of(SourceRange)
			expect(range.null?).to be false
        end

        it "is same to original source range" do
			expect(range).to eq(translation_unit_range)
        end

        it "is same to original source range's locations" do
			expect(range.start).to eq(translation_unit_range.start)
			expect(range.end).to eq(translation_unit_range.end)
        end
    end
end
