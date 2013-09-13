# encoding: UTF-8

require 'cgi'
require 'open-uri'

module MWDictionaryAPI
  class Client
    class << self
      def cache
        @cache ||= MemoryCache
      end

      def cache=(cache)
        @cache = cache
      end

      def parser_class
        @parser_class ||= Parsers::ResultParser
      end

      def parser_class=(parser_class)
        @parser_class = parser_class
      end
    end
    
    
    attr_accessor :api_key, :api_type, :api_endpoint, :response_format

    # search_cache is something that should have the following interface
    #   search_cache.find(term) -> the raw response for the given term
    #   search_cache.add(term, result) -> saves the raw response into the cache
    #   search_cache.remove(term) -> remove the cached response for the term
    #   (optional) search_cache.clear -> clear the cache
    # attr_accessor :search_cache

    def initialize(api_key, api_type: "sd4", response_format: "xml", api_endpoint: API_ENDPOINT)
      @api_key = api_key
      @api_type = api_type
      @response_format = response_format
      @api_endpoint = api_endpoint
    end

    def url_for(word)
      "#{api_endpoint}/#{api_type}/#{response_format}/#{CGI.escape(word)}?key=#{api_key}"
    end

    def search(term, update_cache: false, parser_class: nil)
      if self.class.cache
        if update_cache
          response = fetch_response(term)
          self.class.cache.remove(term)
          self.class.cache.add(term, response)
        else
          response = self.class.cache.find(term)
          unless response
            response = fetch_response(term)
            self.class.cache.add(term, response)
          end
        end
      else
        response = fetch_response(term)
      end
      parser_class = self.class.parser_class if parser_class.nil?
      Result.new(term, response, api_type: api_type, response_format: response_format, parser_class: parser_class)
    end

    def fetch_response(term)
      result = open(url_for(term))
      if result.status[0] != "200" or result.meta["content-type"] != response_format
        raise ResponseException, result.read
      else
        result.read
      end
    end
  end
end