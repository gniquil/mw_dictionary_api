require 'spec_helper'

module MWDictionaryAPI
  describe Parsable do 
    before do
      class Parsor
        include Parsable
      end

      Parsor.rules.clear
    end

    it "has class method parse" do
      expect(Parsor).to respond_to(:rule)
    end

    describe ".rule" do
      it "defines a rule" do
        class Parsor
          rule :head_word, something: :ok do |data, options|
            "a_head_word"
          end
        end

        expect(Parsor.rules[:head_word][:attr_name]).to eq(:head_word)
        expect(Parsor.rules[:head_word][:options]).to eq({something: :ok})
      end

      it "overwrites a rule if attr_name is already defined" do
        class Parsor
          rule :a do |data, options|
            "a"
          end
        end

        class Parsor
          rule :a do |data, options|
            "a!"
          end
        end

        expect(Parsor.rules.count).to eq 1
        expect(Parsor.new.parse(nil)[:a]).to eq "a!"
      end
    end

    describe "#parse" do
      it 'returns parsed result' do
        class Parsor
          rule :head_word do |data, options|
            data[:head_word]
          end
          rule :another_word do |data, options|
            "another_word"
          end
        end

        attributes = Parsor.new.parse({head_word: "head_word1"})
        expect(attributes).to include({head_word: "head_word1", another_word: "another_word"})
        expect(attributes.keys.count).to eq 2
      end
    end

    describe "#new" do
      it 'calls rule block with default options' do
        class Parsor
          rule :default_options, something: :ok do |data, options|
            options
          end
        end
        attributes = Parsor.new(api_type: "collegiate", response_format: "json").parse(nil)
        expect(attributes[:default_options]).to include({
          api_type: "collegiate",
          response_format: "json"
          })
        expect(attributes.keys.count).to eq 1
      end
    end

    describe "inheritance" do
      it "inherited class should not overwrite the original class's rules" do
        class Parsor
          rule :a do |data, options|
            "a"
          end
        end

        class BangParsor < Parsor
          rule :a do |data, options|
            "a!"
          end
        end

        expect(BangParsor.new.parse(nil)[:a]).to eq "a!"
        expect(Parsor.new.parse(nil)[:a]).to eq "a"

        class Parsor
          rule :a do |data, options|
            "aa"
          end
        end

        expect(Parsor.new.parse(nil)[:a]).to eq "aa"
      end

      it "inherited class should extend the original rules" do
        class Parsor
          rule :a do |data, options|
            "a"
          end
        end

        class DoubleBangParsor < Parsor
          rule :b do |data, options|
            "b!!"
          end
        end

        attributes = DoubleBangParsor.new.parse(nil)
        expect(attributes).to include({a: "a", b: "b!!"})
        expect(attributes.count).to eq 2
      end
    end

    describe "calling hidden rules from another rule" do
      it "does not call hidden rules" do
        class Parsor
          rule :bang, hidden: true do |data, options|
            "#{data}!"
          end
        end

        attributes = Parsor.new.parse(nil)
        expect(attributes.count).to eq 0
      end

      it "should return the right values" do
        class Parsor
          rule :bang, hidden: true do |data, options|
            "#{data}!"
          end

          rule :a do |data, options|
            apply_rule(:bang, "a", options)
          end
        end
        parser = Parsor.new
        attributes = parser.parse(nil)
        expect(attributes[:a]).to eq "a!"
        expect(attributes.count).to eq 1
      end
    end

    describe "defining rule helpers" do
      it "allows rules to call these helpers" do
        class Parsor
          rule :a do |data, options|
            bang("a")
          end

          rule_helpers do
            def bang(a)
              "#{a}!"
            end
          end
        end

        attributes = Parsor.new.parse(nil)
        expect(attributes[:a]).to eq "a!"
      end

      it "is safe to call multiple times" do
        class Parsor
          rule :a do |data, options|
            question(bang("a"))
          end

          rule_helpers do
            def bang(a)
              "#{a}!"
            end
          end

          rule_helpers do
            def question(a)
              "#{a}?"
            end
          end
        end

        attributes = Parsor.new.parse(nil)
        expect(attributes[:a]).to eq "a!?"
      end
    end
  end
end