require 'cgi'
require 'open-uri'

module MWDictionaryAPI
  class Client
    class_attribute :search_cache
    class_attribute :API_KEY, :API_ENDPOINT, :PRODUCT_TYPE, :API_FORMAT

    self.search_cache = nil
    self.API_ENDPOINT = "http://www.dictionaryapi.com/api/v1/references"
    self.API_FORMAT = "xml"
    self.PRODUCT_TYPE = "sd4"

    def self.url_for(word)
      "#{self.API_ENDPOINT}/#{self.PRODUCT_TYPE}/#{self.API_FORMAT}/#{CGI.escape(word)}?key=#{self.API_KEY}"
    end

    def self.search(term, update_cache: false)
      if search_cache
        search_cache.remove(term) if update_cache
        raw_doc = search_cache.find(term)
        unless raw_doc
          raw_doc = fetch_raw_doc(term)
          search_cache.add(term, raw_doc)
        end
      else
        raw_doc = fetch_raw_doc(term)
      end
      Result.new(term, raw_doc)
    end

    def self.fetch_raw_doc(term)
      open(url_for(term)).read
    end
  end
end