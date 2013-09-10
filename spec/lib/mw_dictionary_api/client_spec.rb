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
      end

      describe "#search" do
        before do
          allow(client).to receive(:fetch_response).with("one").and_return(File.open(fixture_path("one.xml")).read)
        end

        it "returns a result" do
          result = client.search("one")
          expect(result).to be_a(Result)
        end

        describe ".search with search_cache" do
          class SearchCache

            def self.find(term)
              cache[term]
            end

            def self.add(term, result)
              cache[term] = result
            end

            def self.remove(term)
              cache.delete(term)
            end

            # following methods are optional
            def self.clear
              cache.clear
            end

            def self.cache
              @cache ||= {}
            end

          end

          before do
            client.search_cache = SearchCache
            client.search_cache.clear
          end

          it "should add the result into cache if not found in cache" do
            result = client.search("one")
            expect(client.search_cache.find("one")).to eq result.raw_response
          end

          it "should force refresh of the cache if :update_cache => true and result already exists" do
            expect(client.search_cache).to receive(:add).exactly(2).times.and_call_original
            expect(client.search_cache).to receive(:remove).once.with("one").and_call_original

            result = client.search("one")
            result = client.search("one", update_cache: true)
            result = client.search("one")
          end
        end
      end
    end

    def join_url_segments(client, word)
      "#{client.api_endpoint}/#{client.api_type}/#{client.response_format}/#{word}?key=#{client.api_key}"
    end
  end
end