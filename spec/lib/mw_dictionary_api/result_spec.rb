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
          expect(octopus_result.entries[0][:inflections][0]).to eq({
            inflection_label: "plural", inflected_form: "octopuses"
          })
          expect(octopus_result.entries[0][:inflections][1]).to eq({
            inflection_label: "plural", inflected_form: "octopi"
          })
        end

        it "correctly parses entries with inconsistent sense numbers" do
          expect(result.entries[0][:definitions][0][:sense_number]).to eq "1"
          expect(result.entries[0][:definitions][1][:sense_number]).to eq "2a"
          expect(result.entries[0][:definitions][2][:sense_number]).to eq "2b"
          expect(result.entries[0][:definitions][3][:sense_number]).to eq "3a"
          expect(result.entries[0][:definitions][4][:sense_number]).to eq "3b"
          expect(result.entries[0][:definitions][5][:sense_number]).to eq "4"
          expect(result.entries[0][:definitions][6][:sense_number]).to eq "5"
        end
      end
    end
  end
end