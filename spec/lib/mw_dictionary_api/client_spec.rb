require 'spec_helper'

module MWDictionaryAPI
  describe Client do

    describe "class attributes" do

      it "returns PRODUCT_TYPE when set" do
        Client.PRODUCT_TYPE = "sd4"
        expect(Client.PRODUCT_TYPE).to eq "sd4"
      end

      it "returns API_FORMAT when set" do
        Client.API_FORMAT = "xml"
        expect(Client.API_FORMAT).to eq "xml"
      end

      it "returns API_KEY when set" do
        Client.API_KEY = "1234"
        expect(Client.API_KEY).to eq "1234"
      end

      it "returns default API_ENDPOINT" do
        expect(Client.API_ENDPOINT).to eq "http://www.dictionaryapi.com/api/v1/references"
      end
    end

    describe "class methods" do

      describe ".url_for" do
        it "generates correct query url" do
          word = "something"
          joined_url = join_url_segments(Client.API_ENDPOINT, Client.PRODUCT_TYPE, Client.API_FORMAT, word, Client.API_KEY)
          expect(Client.url_for(word)).to eq joined_url
        end

        context "when searched word has spaces and punctuations" do
          let(:word_with_spaces) { "quid pro quo" }
          let(:word_with_apostrophe) { "isn't" }

          it "generates a valid query url for words with spaces" do
            joined_url = join_url_segments(Client.API_ENDPOINT, Client.PRODUCT_TYPE, Client.API_FORMAT, "quid+pro+quo", Client.API_KEY)

            expect(Client.url_for(word_with_spaces)).to eq joined_url
          end

          it "generates a valid query url for words with apostrophe" do
            joined_url = join_url_segments(Client.API_ENDPOINT, Client.PRODUCT_TYPE, Client.API_FORMAT, "isn%27t", Client.API_KEY)

            expect(Client.url_for(word_with_apostrophe)).to eq joined_url
          end
        end
      end

      describe ".fetch_raw_doc" do
        it "returns a valid xml doc", :external do
          expect do 
            Nokogiri::XML(Client.fetch_raw_doc("one")) do |config|
              config.strict.nonet
            end
          end.not_to raise_error
        end
      end

      describe ".search" do
        it "returns a result" do
          allow(Client).to receive(:fetch_raw_doc).and_return(File.open(fixture_path("one.xml")).read)
          result = Client.search("one")
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
            Client.search_cache = SearchCache
            Client.search_cache.clear
          end

          it "should add the result into cache if not found in cache" do
            result = Client.search("one")
            expect(Client.search_cache.find("one")).to eq result.raw_doc
          end

          it "should force refresh of the cache if :update_cache => true and result already exists", :external do
            expect(Client.search_cache).to receive(:add).exactly(2).times.and_call_original
            expect(Client.search_cache).to receive(:remove).once.with("one").and_call_original

            result = Client.search("one")
            result = Client.search("one", update_cache: true)
            result = Client.search("one")
          end
        end
      end
    end

    def join_url_segments(end_point, product_type, api_format, word, key)
      "#{end_point}/#{product_type}/#{api_format}/#{word}?key=#{key}"
    end
  end
end