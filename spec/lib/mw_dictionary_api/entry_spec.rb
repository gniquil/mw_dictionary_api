require 'spec_helper'

module MWDictionaryAPI

  describe Entry do
    let(:one_raw_doc) { File.open(fixture_path('one.xml')).read }
    let(:one_xml_doc) { Nokogiri::XML(one_raw_doc) }
    let(:one_entry1) { one_xml_doc.css("entry")[0] }
    let(:entry) { Entry.new(one_entry1) }
    let(:octopus_xml_doc) { Nokogiri::XML(File.open(fixture_path('octopus.xml')).read) }
    let(:octopus_entry) { Entry.new(octopus_xml_doc.css("entry")[0]) }
  
    describe "#to_hash" do
      it "returns a hash" do
        expect(octopus_entry.to_hash).to eq({ 
          "id" => 1,
          "word" => "octopus",
          "head_word" => "oc*to*pus",
          "pronunciation" => "ˈäk-tə-pəs",
          "part_of_speech" => "noun",
          "inflections" => {
            "plural" => [
              "octopuses",
              "octopi"
            ]
          },
          "definitions" => [
            {
              "sense_number" => "1", 
              "cross_reference" => [], 
              "verbal_illustration" => nil, 
              "text" => ":any of various cephalopod sea mollusks having eight muscular arms with two rows of suckers" 
            },
            {
              "sense_number" => "2", 
              "cross_reference" => [], 
              "verbal_illustration" => nil, 
              "text" => ":something suggestive of an octopus especially in having many centrally directed branches" 
            }
          ]
        })
        expect(entry.to_hash).to eq({ 
          "id" => 1,
          "word" => "one",
          "head_word" => "one",
          "pronunciation" => "ˈwən, ˌwən",
          "part_of_speech" => "adjective",
          "inflections" => {},
          "definitions" => [
            {
              "sense_number" => "1", 
              "cross_reference" => [], 
              "verbal_illustration" => "one person left", 
              "text" => ":being a single unit or thing" 
            },
            {
              "sense_number" => "2a", 
              "cross_reference" => [], 
              "verbal_illustration" => "early one morning", 
              "text" => ":being one in particular" 
            },
            {
              "sense_number" => "2b", 
              "cross_reference" => [], 
              "verbal_illustration" => "one fine person", 
              "text" => ":being notably what is indicated" 
            },
            {
              "sense_number" => "3a", 
              "cross_reference" => [], 
              "verbal_illustration" => "both of one species", 
              "text" => ":being the same in kind or quality" 
            },
            {
              "sense_number" => "3b", 
              "cross_reference" => ["united"], 
              "verbal_illustration" => "am one with you on this", 
              "text" => ":not divided :united" 
            },
            {
              "sense_number" => "4", 
              "cross_reference" => ["some 1"], 
              "verbal_illustration" => "will see you again one day", 
              "text" => ":some 1" 
            },
            {
              "sense_number" => "5", 
              "cross_reference" => ["only 2a"], 
              "verbal_illustration" => "the one person they wanted to see", 
              "text" => ":only 2a" 
            }
          ]
        })
      end
    end

  end
end