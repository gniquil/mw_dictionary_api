# encoding: UTF-8

require 'spec_helper'

describe "General use cases" do
  let(:response_content) { File.open(fixture_path("one.xml")).read }

  before do
    MWDictionaryAPI::Client.any_instance.stub(:fetch_response).with("one").and_return(response_content)
  end

  describe "Querying" do
  
    specify "querying the SD4 api" do
      client = MWDictionaryAPI::Client.new(ENV['MW_API_KEY'])
      result = client.search("one")

      expect(result.entries.count).to eq 10
      expect(result.suggestions.count).to eq 0
    end

    specify "querying an alternate api" do
      client = MWDictionaryAPI::Client.new(ENV['MW_API_KEY'], api_type: "collegiate")

      expect(client.api_type).to eq "collegiate"
      expect(client.url_for("one")).to match /collegiate/
    end

    specify "querying an alternate api after creating the client" do
      client = MWDictionaryAPI::Client.new(ENV['MW_API_KEY'])
      client.api_type = "collegiate"

      expect(client.api_type).to eq "collegiate"
      expect(client.url_for("one")).to match /collegiate/
    end
  end

  describe "Custom Cache" do
    specify "alternate cache should be used" do
      class SimpleCache
        def self.find(term)
          cache[term]
        end

        def self.add(term, result)
          cache[term] = result
        end

        def self.remove(term)
          cache.delete(term)
        end

        def self.clear
          cache.clear
        end

        # non-required methods
        def self.cache
          @cache ||= {}
        end
      end
      MWDictionaryAPI::MemoryCache.clear
      SimpleCache.clear

      MWDictionaryAPI::Client.cache = SimpleCache
      client = MWDictionaryAPI::Client.new(ENV['MW_API_KEY'])
      client.search("one")

      expect(SimpleCache.find("one")).to eq response_content
      expect(MWDictionaryAPI::MemoryCache.find("one")).to be_nil
    end
  end

  describe "Custom Parser" do
    let(:client) { MWDictionaryAPI::Client.new(ENV['MW_API_KEY']) }

    specify "using a custom parser by extending default parser" do
      class IgnorantParser < MWDictionaryAPI::Parsers::ResultParser
        rule :entries do |data, opts|
          []
        end

        rule :suggestions do |data, opts|
          []
        end
      end

      result = client.search("one", parser_class: IgnorantParser)

      expect(result.parser_class).to eq IgnorantParser
      expect(result.entries).to eq []
      expect(result.suggestions).to eq []
    end

    specify "creating parser from scratch" do
      class EchoParser
        include MWDictionaryAPI::Parsable

        rule :entries do |data, opts|
          "entries"
        end

        rule :suggestions do |data, opts|
          "suggestions"
        end
      end

      result = client.search("one", parser_class: EchoParser)

      expect(result.parser_class).to eq EchoParser
      expect(result.entries).to eq "entries"
      expect(result.suggestions).to eq "suggestions"
    end

    specify "configuring custom parser at the Client class" do
      class SimpleParser
        include MWDictionaryAPI::Parsable
        rule :entries do |data, opts|
          "simple"
        end
      end
      
      MWDictionaryAPI::Client.parser_class = SimpleParser
      result = client.search("one")

      expect(result.parser_class).to eq SimpleParser
      expect(result.entries).to eq "simple"
      expect(result.suggestions).to be_nil
    end

  end
end
