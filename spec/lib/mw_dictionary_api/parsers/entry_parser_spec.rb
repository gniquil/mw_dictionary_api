# encoding: UTF-8

require 'spec_helper'

module MWDictionaryAPI
  module Parsers
    describe EntryParser do
      let(:one_raw_doc) { File.open(fixture_path('one.xml')).read }
      let(:one_xml_doc) { Nokogiri::XML(one_raw_doc) }
      let(:one_entry1) { one_xml_doc.css("entry")[0] }
      let(:one_entry2) { one_xml_doc.css("entry")[1] }
      let(:one_entry3) { one_xml_doc.css("entry")[2] }
      let(:particularity_xml_doc) { Nokogiri::XML(File.open(fixture_path('particularity.xml')).read) }
      let(:particularity_entry) { particularity_xml_doc.at_css("entry") }
      let(:octopus_xml_doc) { Nokogiri::XML(File.open(fixture_path('octopus.xml')).read) }
      let(:octopus_entry) { octopus_xml_doc.at_css("entry") }
      let(:one_collegiate_xml_doc) { Nokogiri::XML(File.open(fixture_path('one_collegiate.xml')).read) }
      let(:one_collegiate_entry) { one_collegiate_xml_doc.at_css("entry") }

      let(:shrift_collegiate_entry) { Nokogiri::XML(File.open(fixture_path('shrift_collegiate.xml')).read).at_css("entry") }

      let(:parser) { EntryParser.new }

      def parse(data)
        parser.parse(data)
      end

      it "returns the word" do
        expect(parse(one_entry1)[:word]).to eq "one"
        expect(parse(one_entry2)[:word]).to eq "one"
        expect(parse(one_entry3)[:word]).to eq "one"
      end

      it "returns the entry id" do
        expect(parse(one_entry1)[:id]).to eq 1
        expect(parse(one_entry2)[:id]).to eq 2
        expect(parse(one_entry3)[:id]).to eq 3
      end

      it "returns the entry id_attribute" do
        expect(parse(one_entry1)[:id_attribute]).to eq "one[1]"
        expect(parse(one_entry2)[:id_attribute]).to eq "one[2]"
        expect(parse(one_entry3)[:id_attribute]).to eq "one[3]"
      end

      it "returns 1 when id is not available" do
        expect(parse(octopus_xml_doc.at_css("entry"))[:id]).to eq 1
      end

      it "returns the head_word" do
        expect(parse(one_entry1)[:head_word]).to eq "one"
      end

      it "returns the pronunciation" do
        expect(parse(one_entry1)[:pronunciation]).to eq "ˈwən, ˌwən"
      end

      it "returns the part of speech" do
        expect(parse(one_entry1)[:part_of_speech]).to eq "adjective"
      end

      it "returns the name of sound file" do
        expect(parse(one_entry1)[:sound]).to eq "one00001.wav"
      end

      describe "inflections" do
        let(:inflections) { parse(one_entry1)[:inflections] }
        let(:particularity_inflections) { parse(particularity_entry)[:inflections] }
        let(:octopus_inflections) { parse(octopus_entry)[:inflections] }

        it "returns a list of inflections if available" do
          expect(inflections).to be_empty
          expect(particularity_inflections).to eq([{
            inflection_label: "plural",
            inflected_form: "particularities"
          }])
          expect(octopus_inflections).to eq([
            { inflection_label: "plural", inflected_form: "octopuses" },
            { inflection_label: "plural", inflected_form: "octopi"}
          ])
        end

        context "when <in> elements repeat and <il> is absent" do
          let(:funny_xml_doc) { Nokogiri::XML(File.open(fixture_path('funny.xml')).read) }
          let(:funny1_entry) { funny_xml_doc.css("entry")[0] }

          it 'returns the correct list of inflections' do
            inflections = parse(funny1_entry)[:inflections]
            expect(inflections.count).to eq 2
            expect(inflections).to eq([
              { inflected_form: "funnier" },
              { inflected_form: "funniest" }
            ])
          end
        end
      end

      describe "definitions" do
        it 'returns a list of definition pairs' do
          definitions = parse(shrift_collegiate_entry)[:definitions]
          expect(definitions.count).to eq 4
        end
      end
    end
  end
end
