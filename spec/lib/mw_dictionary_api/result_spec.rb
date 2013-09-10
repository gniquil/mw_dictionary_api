require 'spec_helper'

module MWDictionaryAPI
  describe Result do
    let(:word) { "one" }
    let(:raw_doc) { File.open(fixture_path("one.xml")).read }
    let(:result) { Result.new(word, raw_doc) }

    describe "attributes" do
      it "has searched_word attribute" do
        expect(result.searched_word).to eq word
      end

      it "has raw_doc attribute" do
        expect(result.raw_doc).to eq raw_doc
      end
    end

    describe "#entries" do
      it 'returns a list of entries without [] duplicates' do
        doc = Nokogiri::XML(raw_doc)
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
        expect(result.entries.count).to eq expected_keys.count
        expect(result.entries.keys).to eq expected_keys
        result.entries.each do |key, entry_array|
          expect(entry_array).to be_an(Array)
          entry_array.each do |entry|
            expect(entry).to be_an(Entry)
          end
        end
      end
    end

    describe "#entries_as_array" do
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
        result.entries_as_array.each_index do |index|
          expect(result.entries_as_array[index].word).to eq expected_keys[index]
        end
      end
    end

    describe ".parse_word_and_index" do
      it 'returns word and word_index' do
        word, word_index = Result.parse_word_and_index('one[3]')
        expect(word).to eq 'one'
        expect(word_index).to eq 3
        word, word_index = Result.parse_word_and_index('another[234]')
        expect(word).to eq 'another'
        expect(word_index).to eq 234
      end

      it 'returns word and 1 when no word_index' do
        expect(Result.parse_word_and_index('one')).to eq ['one', 1]
      end

      it 'returns "" and 1 when "" given' do
        expect{ Result.parse_word_and_index('') }.to raise_error(ArgumentError)
      end
    end

  end
end