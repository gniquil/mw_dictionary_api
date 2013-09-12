require 'spec_helper'

module MWDictionaryAPI
  describe Result do
    let(:word) { "one" }
    let(:raw_response) { File.open(fixture_path("one.xml")).read }
    let(:result) { Result.new(word, raw_response) }

    describe "attributes" do
      it "has term attribute" do
        expect(result.term).to eq word
      end

      it "has raw_response attribute" do
        expect(result.raw_response).to eq raw_response
      end
    end

    describe "#to_hash" do
      it "returns a hash" do
        expect(result.to_hash).to eq({
          "term" => "one",
          "entries" => result.entries.map { |e| e.to_hash },
          "suggestions" => []
        })
      end
    end
  end
end