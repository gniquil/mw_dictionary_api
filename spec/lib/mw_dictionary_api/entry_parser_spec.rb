require 'spec_helper'

module MWDictionaryAPI
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

    describe "#construct_sense_number" do
      it { expect(EntryParser.apply_rule(:def_sense_number, {sn: "2", prev_sn: nil}, nil)).to eq "2" }
      it { expect(EntryParser.apply_rule(:def_sense_number, {sn: "2", prev_sn: "1"}, nil)).to eq "2" }
      it { expect(EntryParser.apply_rule(:def_sense_number, {sn: "2", prev_sn: "1a"}, nil)).to eq "2" }
      it { expect(EntryParser.apply_rule(:def_sense_number, {sn: "2", prev_sn: "1a(1)"}, nil)).to eq "2" }
      it { expect(EntryParser.apply_rule(:def_sense_number, {sn: "2a", prev_sn: "1"}, nil)).to eq "2a" }
      it { expect(EntryParser.apply_rule(:def_sense_number, {sn: "2a", prev_sn: "1a"}, nil)).to eq "2a" }
      it { expect(EntryParser.apply_rule(:def_sense_number, {sn: "2a", prev_sn: "1a(1)"}, nil)).to eq "2a" }
      it { expect(EntryParser.apply_rule(:def_sense_number, {sn: "2a(1)", prev_sn: "1"}, nil)).to eq "2a(1)" }
      it { expect(EntryParser.apply_rule(:def_sense_number, {sn: "2a(1)", prev_sn: "1b"}, nil)).to eq "2a(1)" }
      it { expect(EntryParser.apply_rule(:def_sense_number, {sn: "2a(1)", prev_sn: "1b(1)"}, nil)).to eq "2a(1)" }
      it { expect(EntryParser.apply_rule(:def_sense_number, {sn: "b", prev_sn: "1a"}, nil)).to eq "1b" }
      it { expect(EntryParser.apply_rule(:def_sense_number, {sn: "b", prev_sn: "1a(1)"}, nil)).to eq "1b" }
      it { expect(EntryParser.apply_rule(:def_sense_number, {sn: "b", prev_sn: "a"}, nil)).to eq "b" }
      it { expect(EntryParser.apply_rule(:def_sense_number, {sn: "b", prev_sn: "(1)"}, nil)).to eq "b" }
      it { expect(EntryParser.apply_rule(:def_sense_number, {sn: "(2)", prev_sn: "1a(1)"}, nil)).to eq "1a(2)" }
      it { expect(EntryParser.apply_rule(:def_sense_number, {sn: "(2)", prev_sn: "a(1)"}, nil)).to eq "a(2)" }
      it { expect(EntryParser.apply_rule(:def_sense_number, {sn: "(2)", prev_sn: "(1)"}, nil)).to eq "(2)" }
    end

    describe "definitions" do
      let(:definitions) { parse(one_entry1)[:definitions] }
      let(:collegiate_definitions) { parse(one_collegiate_entry)[:definitions] }

      it "show an non-empty list" do
        expect(definitions.count).to eq 7
      end

      it "should not be confused by non dt/sn elements" do
        expect(collegiate_definitions[0]["text"]).not_to eq "before 12th century"
      end

      describe "individual definition" do
        it "returns the verbal illustration" do
          expect(definitions[0]["verbal_illustration"]).to eq "one person left"
        end

        it "returns the cross reference" do
          expect(definitions[4]["cross_reference"]).to eq ["united"]
          expect(definitions[6]["cross_reference"]).to eq ["only 2a"]
        end

        it "returns the text" do
          expect(definitions[0]["text"]).to eq ":being a single unit or thing"
        end
      end
    end

    describe "inflections" do
      let(:inflections) { parse(one_entry1)[:inflections] }
      let(:particularity_inflections) { parse(particularity_entry)[:inflections] }
      let(:octopus_inflections) { parse(octopus_entry)[:inflections] }

      it "returns a list of inflections if available" do
        expect(inflections).to be_empty
        expect(particularity_inflections).to eq({ "plural" => ["particularities"] })
        expect(octopus_inflections).to eq({"plural" => ["octopuses", "octopi"]})
      end
    end

  end
end