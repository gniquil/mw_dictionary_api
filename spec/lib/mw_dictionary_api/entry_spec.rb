require 'spec_helper'

module MWDictionaryAPI

  describe Entry do
    let(:one_raw_doc) { File.open(fixture_path('one.xml')).read }
    let(:one_xml_doc) { Nokogiri::XML(one_raw_doc) }
    let(:one_entry1) { one_xml_doc.css("entry")[0] }
    let(:one_entry2) { one_xml_doc.css("entry")[1] }
    let(:one_entry3) { one_xml_doc.css("entry")[2] }
    let(:entry) { Entry.new(one_entry1) }
    let(:entry2) { Entry.new(one_entry2) }
    let(:entry3) { Entry.new(one_entry3) }
    let(:particularity_xml_doc) { Nokogiri::XML(File.open(fixture_path('particularity.xml')).read) }
    let(:particularity_entry) { Entry.new(particularity_xml_doc.css("entry")[0]) }
    let(:octopus_xml_doc) { Nokogiri::XML(File.open(fixture_path('octopus.xml')).read) }
    let(:octopus_entry) { Entry.new(octopus_xml_doc.css("entry")[0]) }
    let(:one_collegiate_xml_doc) { Nokogiri::XML(File.open(fixture_path('one_collegiate.xml')).read) }
    let(:one_collegiate_entry) { Entry.new(one_collegiate_xml_doc.css("entry")[0])}
    
    describe "attributes" do
      
      it "returns the word" do
        expect(entry.word).to eq "one"
        expect(entry2.word).to eq "one"
        expect(entry3.word).to eq "one"
      end

      it "returns the entry id" do
        expect(entry.id).to eq 1
        expect(entry2.id).to eq 2
        expect(entry3.id).to eq 3
      end

      it "returns the entry id_attribute" do
        expect(entry.id_attribute).to eq "one[1]"
        expect(entry2.id_attribute).to eq "one[2]"
        expect(entry3.id_attribute).to eq "one[3]"
      end

      it "returns 1 when id is not available" do
        expect(octopus_entry.id).to eq 1
      end

      it "returns the head_word" do
        expect(entry.head_word).to eq "one"
      end

      it "returns the pronunciation" do
        expect(entry.pronunciation).to eq "ˈwən, ˌwən"
      end

      it "returns the part of speech" do
        expect(entry.part_of_speech).to eq "adjective"
      end

      it "returns the name of sound file" do 
        expect(entry.sound).to eq "one00001.wav"
      end

      describe "#parse_word_and_index" do
        it 'returns word and word_index' do
          entry.instance_variable_set(:@id_attribute, 'one[3]')
          word, word_index = entry.parse_word_and_index
          expect(word).to eq 'one'
          expect(word_index).to eq 3

          entry.instance_variable_set(:@id_attribute, 'another[234]')
          word, word_index = entry.parse_word_and_index
          expect(word).to eq 'another'
          expect(word_index).to eq 234
        end

        it 'returns word and 1 when no word_index' do
          entry.instance_variable_set(:@id_attribute, 'one')
          expect(entry.parse_word_and_index).to eq ['one', 1]
        end

      end

      describe "#definitions" do
        it "returns a list of definitions" do
          expect(entry.definitions).to be_an(Array)
          entry.definitions.each do |d|
            expect(d).to be_a(Definition)
          end
        end

        it "show an non-empty list" do
          pp entry.to_hash
          expect(entry.definitions.count).to eq 7
        end

        it "should not be confused by non dt/sn elements" do
          expect(one_collegiate_entry.definitions.first.text).not_to eq "before 12th century"
        end
      end

      describe "#inflections" do
        it "returns a list of inflections if available" do
          expect(entry.inflections).to be_empty
          expect(particularity_entry.inflections).to eq({ "plural" => ["particularities"] })
          expect(octopus_entry.inflections).to eq({"plural" => ["octopuses", "octopi"]})
        end
      end

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
end