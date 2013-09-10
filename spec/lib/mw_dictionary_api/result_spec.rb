require 'spec_helper'

module MWDictionaryAPI
  describe Result do
    let(:word) { "one" }
    let(:raw_response) { File.open(fixture_path("one.xml")).read }
    let(:result) { Result.new(word, raw_response, "sd4") }

    describe "attributes" do
      it "has searched_word attribute" do
        expect(result.searched_word).to eq word
      end

      it "has raw_response attribute" do
        expect(result.raw_response).to eq raw_response
      end
    end

    describe "#entries_group_by_word" do
      it 'returns a list of entries without [] duplicates' do
        doc = Nokogiri::XML(raw_response)
        expected_keys = [
          'one',
          'one another',
          'one-dimensional',
          'one-horse',
          'one-man',
          'one-on-one',
          'one-piece',
          'one-sided'
        ]
        expect(result.entries_group_by_word.keys).to eq expected_keys
        result.entries_group_by_word.each do |key, entry_array|
          expect(entry_array).to be_an(Array)
          entry_array.each do |entry|
            expect(entry).to be_an(Entry)
          end
        end
      end
    end

    describe "#entries" do
      it "returns a list of entries with duplicates" do
        expected_keys = [
          'one',
          'one',
          'one',
          'one another',
          'one-dimensional',
          'one-horse',
          'one-man',
          'one-on-one',
          'one-piece',
          'one-sided'
        ]
        result.entries.each_index do |index|
          expect(result.entries[index].word).to eq expected_keys[index]
        end
      end
    end

  end
end