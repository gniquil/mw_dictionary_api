require 'spec_helper'

module MWDictionaryAPI
  describe Definition do
    let(:one_raw_doc) { File.open(fixture_path('one.xml')).read }
    let(:one_xml_doc) { Nokogiri::XML(one_raw_doc) }
    let(:one_entry1_entity) { one_xml_doc.css("entry")[0] }
    let(:one_entry2_entity) { one_xml_doc.css("entry")[1] }
    let(:one_entry3_entity) { one_xml_doc.css("entry")[2] }
    let(:one_another_entry_entity) { one_xml_doc.css("entry")[3] }
    let(:entry) { Entry.new(one_entry1_entity) }
    let(:one_another_entry) { Entry.new(one_another_entry_entity) }
    let(:one_collegiate_xml_doc) { Nokogiri::XML(File.open(fixture_path('one_collegiate.xml')).read) }
    let(:one_collegiate_entry) { Entry.new(one_collegiate_xml_doc.css("entry")[0])}


    describe "attributes" do

      it "returns the sense number if available" do
        expect(entry.definitions.first.sense_number).to eq "1"
      end

      it "returns '1' if sense number is missing" do
        expect(one_another_entry.definitions.first.sense_number).to eq "1"
      end

      it "returns a sense number with full format eg: 1a(1)" do
        expect(entry.definitions[0].sense_number).to eq "1"
        expect(entry.definitions[1].sense_number).to eq "2a"
        expect(entry.definitions[2].sense_number).to eq "2b"
        expect(entry.definitions[3].sense_number).to eq "3a"
        expect(entry.definitions[4].sense_number).to eq "3b"
        expect(entry.definitions[5].sense_number).to eq "4"
        expect(entry.definitions[6].sense_number).to eq "5"

        expect(one_collegiate_entry.definitions[4].sense_number).to eq "3b(1)"
        expect(one_collegiate_entry.definitions[5].sense_number).to eq "3b(2)"
      end

      it "returns the verbal illustration" do
        expect(entry.definitions.first.verbal_illustration).to eq "one person left"
      end

      it "returns the cross reference" do
        expect(entry.definitions[4].cross_reference).to eq ["united"]
        expect(entry.definitions[6].cross_reference).to eq ["only 2a"]
      end

      it "returns the text" do
        expect(entry.definitions.first.text).to eq ":being a single unit or thing"
      end

    end

    describe "#construct_sense_number" do
      it { expect(entry.definitions.first.construct_sense_number("2", "1a")).to eq "2" }
      it { expect(entry.definitions.first.construct_sense_number("2", nil)).to eq "2" }
      it { expect(entry.definitions.first.construct_sense_number("b", "1a")).to eq "1b" }
      it { expect(entry.definitions.first.construct_sense_number("2", "1a")).to eq "2" }
      it { expect(entry.definitions.first.construct_sense_number("2a", "1a")).to eq "2a" }

      it { expect(entry.definitions.first.construct_sense_number("2a(1)", "1 b")).to eq "2a(1)" }
      it { expect(entry.definitions.first.construct_sense_number("2a(1)", "1")).to eq "2a(1)" }
      it { expect(entry.definitions.first.construct_sense_number("(2)", "1a(1)")).to eq "1a(2)" }
      it { expect(entry.definitions.first.construct_sense_number("b", "1a(1)")).to eq "1b" }
      it { expect(entry.definitions.first.construct_sense_number("2", "1a(1)")).to eq "2" }
    end

    describe "#to_hash" do
      it "returns a hash" do
        expect(entry.definitions.first.to_hash).to eq({ 
          "sense_number" => "1", 
          "cross_reference" => [], 
          "verbal_illustration" => "one person left", 
          "text" => ":being a single unit or thing" 
        })
        expect(entry.definitions[4].to_hash).to eq({ 
          "sense_number" => "3b", 
          "cross_reference" => ["united"], 
          "verbal_illustration" => "am one with you on this", 
          "text" => ":not divided :united" 
        })
      end
    end
  end
end