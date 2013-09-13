# encoding: UTF-8

require 'spec_helper'

module MWDictionaryAPI
  describe Client do

    let(:client) { Client.new(ENV['MW_API_KEY']) }

    describe "attributes" do

      it "returns api_type when set" do
        expect(client.api_type).to eq "sd4"
      end

      it "returns response_format when set" do
        expect(client.response_format).to eq "xml"
      end

      it "returns api_key when set" do
        expect(client.api_key).to eq ENV['MW_API_KEY']
      end

      it "returns api_endpoint" do
        expect(client.api_endpoint).to eq "http://www.dictionaryapi.com/api/v1/references"
      end
    end

    describe "methods" do

      describe "#url_for" do
        it "generates correct query url" do
          word = "something"
          joined_url = join_url_segments(client, word)
          expect(client.url_for(word)).to eq joined_url
        end

        context "when searched word has spaces and punctuations" do
          let(:word_with_spaces) { "quid pro quo" }
          let(:word_with_apostrophe) { "isn't" }

          it "generates a valid query url for words with spaces" do
            joined_url = join_url_segments(client, "quid+pro+quo")

            expect(client.url_for(word_with_spaces)).to eq joined_url
          end

          it "generates a valid query url for words with apostrophe" do
            joined_url = join_url_segments(client, "isn%27t")

            expect(client.url_for(word_with_apostrophe)).to eq joined_url
          end
        end
      end

      describe "#fetch_response" do
        it "returns a valid xml doc", :external do
          expect do 
            Nokogiri::XML(client.fetch_response("one")) do |config|
              config.strict.nonet
            end
          end.not_to raise_error
        end

        describe "invalid responses", :external do
          it "raises MWDictionaryAPI::ResponseException when api_key is incorrect" do
            client.api_key = '123'
            expect {
              client.search('one')
            }.to raise_error(ResponseException, "Invalid API key or reference name provided.")
          end
        end
      end

      describe "#search" do
        let(:response_content) { File.open(fixture_path("one.xml")).read }
        before do
          allow(client).to receive(:fetch_response).with("one").and_return(response_content)
        end
        
        describe ".search with search_cache" do
          it "should add the result into cache if not found in cache" do
            result = client.search("one")
            expect(Client.cache.find("one")).to eq result.raw_response
          end

          it "should force refresh of the cache if :update_cache => true and result already exists" do
            expect(Client.cache).to receive(:add).exactly(2).times.and_call_original
            expect(Client.cache).to receive(:remove).once.with("one").and_call_original

            result = client.search("one")
            result = client.search("one", update_cache: true)
            result = client.search("one")
          end

          it "should preserve previous cache if connection is lost when force refresh" do 
            result = client.search("one")
            expect(Client.cache.find("one")).not_to be_empty
            expect(client).to receive(:fetch_response).and_raise(SocketError)
            expect {
              result = client.search("one", update_cache: true)  
            }.to raise_error(SocketError)
            expect(Client.cache.find("one")).not_to be_empty
          end
        end

        describe "configuring the cache" do
          it "should use the custom cache" do
            class SimpleCache
              def find(term)
                @cache[term]
              end

              def add(term, result)
                @cache[term] = result
              end

              def remove(term)
                @cache.delete(term)
              end

              def clear
                @cache.clear
              end

              # non-required methods
              def initialize(cache)
                @cache = cache
              end
            end

            cache_hash = {}

            Client.cache = SimpleCache.new(cache_hash)

            client.search("one")
            expect(cache_hash.fetch("one")).to eq response_content
            expect(MemoryCache.find("one")).to be_nil
          end
        end

        describe "searching with a custom parser class" do
          it "returns a result with the custom class" do
            class SimpleParser
              include Parsable

              rule :entries do |data, opts|
                "simple"
              end
            end

            result = client.search("one", parser_class: SimpleParser)
            expect(result.parser_class).to eq SimpleParser
            expect(result.entries).to eq "simple"
            expect(result.suggestions).to eq nil
          end
        end

        describe "handling invalid search" do
          before do
            allow(client).to receive(:fetch_response).with("onet").and_return(File.open(fixture_path("onet.xml")).read)
          end

          it "should return a list of suggestions if the word is invalid" do
            result = client.search("onet")
            expect(result.entries).to be_empty
            expect(result.suggestions.count).to be > 0
          end

          it "should return empty suggestions if the word is valid" do
            result = client.search("one")
            expect(result.entries).not_to be_empty
            expect(result.suggestions).to be_empty
          end
        end
      end
    end

    def join_url_segments(client, word)
      "#{client.api_endpoint}/#{client.api_type}/#{client.response_format}/#{word}?key=#{client.api_key}"
    end
  end
end