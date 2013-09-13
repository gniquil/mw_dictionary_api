# encoding: UTF-8

require 'spec_helper'

module MWDictionaryAPI
  describe Result do
    let(:raw_response) { File.open(fixture_path("one.xml")).read }
    let(:result) { Result.new("one", raw_response) }
    let(:octopus_raw_response) { File.open(fixture_path('octopus.xml')).read }
    let(:octopus_result) { Result.new("octopus", octopus_raw_response)}

    describe "attributes" do
      it "has term attribute" do
        expect(result.term).to eq "one"
      end

      it "has raw_response attribute" do
        expect(result.raw_response).to eq raw_response
      end

      it "returns the correct number of defintions" do 
        expect(result.entries.count).to eq 10
        expect(octopus_result.entries.count).to eq 1
      end
    end

    describe "using a custom parser" do
      before do
        class SimpleParser
          include Parsable

          rule :entries do |data, opts|
            "simple"
          end
        end
      end
      
      it "parses the response using the custom parser" do
        simple_result = Result.new("one", raw_response, parser_class: SimpleParser)
        expect(simple_result.parser_class).to eq SimpleParser
        expect(simple_result.entries).to eq "simple"
        expect(simple_result.suggestions).to eq nil
      end

      describe "#parse!" do
        it "should reparse the raw_response" do
          expect(result.entries.count).to eq 10
          result.parser_class = SimpleParser
          result.parse!
          expect(result.entries).not_to be_an(Array)
        end
      end
    end


    describe "#to_hash" do
      it "returns a hash" do
        expect(result.to_hash).to eq({
          term: "one",
          entries: result.entries,
          suggestions: []
        })
      end

      describe "entries" do
        it "correctly parses entries with inflections" do
          expect(octopus_result.entries[0]).to include({ 
            id: 1,
            word: "octopus",
            head_word: "oc*to*pus",
            pronunciation: "ˈäk-tə-pəs",
            part_of_speech: "noun",
            inflections: {
              plural: [
                "octopuses",
                "octopi"
              ]
            },
            definitions: [
              {
                sense_number: "1", 
                cross_reference: [], 
                verbal_illustration: nil, 
                text: ":any of various cephalopod sea mollusks having eight muscular arms with two rows of suckers" 
              },
              {
                sense_number: "2", 
                cross_reference: [], 
                verbal_illustration: nil, 
                text: ":something suggestive of an octopus especially in having many centrally directed branches" 
              }
            ]
          })
        end

        it "correctly parses entries with inconsistent sense numbers" do
          expect(result.entries[0]).to include({ 
            id: 1,
            word: "one",
            head_word: "one",
            pronunciation: "ˈwən, ˌwən",
            part_of_speech: "adjective",
            inflections: {},
            definitions: [
              {
                sense_number: "1", 
                cross_reference: [], 
                verbal_illustration: "one person left", 
                text: ":being a single unit or thing" 
              },
              {
                sense_number: "2a", 
                cross_reference: [], 
                verbal_illustration: "early one morning", 
                text: ":being one in particular" 
              },
              {
                sense_number: "2b", 
                cross_reference: [], 
                verbal_illustration: "one fine person", 
                text: ":being notably what is indicated" 
              },
              {
                sense_number: "3a", 
                cross_reference: [], 
                verbal_illustration: "both of one species", 
                text: ":being the same in kind or quality" 
              },
              {
                sense_number: "3b", 
                cross_reference: ["united"], 
                verbal_illustration: "am one with you on this", 
                text: ":not divided :united" 
              },
              {
                sense_number: "4", 
                cross_reference: ["some 1"], 
                verbal_illustration: "will see you again one day", 
                text: ":some 1" 
              },
              {
                sense_number: "5", 
                cross_reference: ["only 2a"], 
                verbal_illustration: "the one person they wanted to see", 
                text: ":only 2a" 
              }
            ]
          })
        end
      end
    end
  end
end