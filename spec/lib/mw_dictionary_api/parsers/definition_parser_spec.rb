# encoding: UTF-8

require 'spec_helper'

module MWDictionaryAPI
  module Parsers
    describe DefinitionParser do
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
      
      let(:parser) { EntryParser.new }

      def parse(data)
        parser.parse(data)
      end
        
      def apply_rule(*args)
        DefinitionParser.apply_rule(*args)
      end

      describe "#construct_sense_number" do
        it { expect(apply_rule(:sense_number, {sn: "2", prev_sn: nil}, nil)).to eq "2" }
        it { expect(apply_rule(:sense_number, {sn: "2", prev_sn: "1"}, nil)).to eq "2" }
        it { expect(apply_rule(:sense_number, {sn: "2", prev_sn: "1a"}, nil)).to eq "2" }
        it { expect(apply_rule(:sense_number, {sn: "2", prev_sn: "1a(1)"}, nil)).to eq "2" }
        it { expect(apply_rule(:sense_number, {sn: "2a", prev_sn: "1"}, nil)).to eq "2a" }
        it { expect(apply_rule(:sense_number, {sn: "2a", prev_sn: "1a"}, nil)).to eq "2a" }
        it { expect(apply_rule(:sense_number, {sn: "2a", prev_sn: "1a(1)"}, nil)).to eq "2a" }
        it { expect(apply_rule(:sense_number, {sn: "2a(1)", prev_sn: "1"}, nil)).to eq "2a(1)" }
        it { expect(apply_rule(:sense_number, {sn: "2a(1)", prev_sn: "1b"}, nil)).to eq "2a(1)" }
        it { expect(apply_rule(:sense_number, {sn: "2a(1)", prev_sn: "1b(1)"}, nil)).to eq "2a(1)" }
        it { expect(apply_rule(:sense_number, {sn: "b", prev_sn: "1a"}, nil)).to eq "1b" }
        it { expect(apply_rule(:sense_number, {sn: "b", prev_sn: "1a(1)"}, nil)).to eq "1b" }
        it { expect(apply_rule(:sense_number, {sn: "b", prev_sn: "a"}, nil)).to eq "b" }
        it { expect(apply_rule(:sense_number, {sn: "b", prev_sn: "(1)"}, nil)).to eq "b" }
        it { expect(apply_rule(:sense_number, {sn: "(2)", prev_sn: "1a(1)"}, nil)).to eq "1a(2)" }
        it { expect(apply_rule(:sense_number, {sn: "(2)", prev_sn: "a(1)"}, nil)).to eq "a(2)" }
        it { expect(apply_rule(:sense_number, {sn: "(2)", prev_sn: "(1)"}, nil)).to eq "(2)" }
      end

      let(:definitions) { parse(one_entry1)[:definitions] }
      let(:collegiate_definitions) { parse(one_collegiate_entry)[:definitions] }

      it "show an non-empty list" do
        expect(definitions.count).to eq 7
      end

      it "should not be confused by non dt/sn elements" do
        expect(collegiate_definitions[0][:text]).not_to eq "before 12th century"
      end

      describe "individual definition" do
        it "returns the verbal illustration" do
          expect(definitions[0][:verbal_illustration]).to eq "one person left"
        end

        it "returns the cross reference" do
          expect(definitions[4][:cross_reference]).to eq ["united"]
          expect(definitions[6][:cross_reference]).to eq ["only 2a"]
        end

        it "returns the text" do
          expect(definitions[0][:text]).to eq ":being a single unit or thing"
        end
      end
    
    end
  end
end