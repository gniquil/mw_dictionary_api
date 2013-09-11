require 'cgi'
require 'open-uri'

module MWDictionaryAPI
  class Client
    
    attr_accessor :api_key, :api_type, :api_endpoint, :response_format

    # search_cache is something that should have the following interface
    #   search_cache.find(term) -> the raw response for the given term
    #   search_cache.add(term, result) -> saves the raw response into the cache
    #   search_cache.remove(term) -> remove the cached response for the term
    #   (optional) search_cache.clear -> clear the cache
    attr_accessor :search_cache

    def initialize(api_key, api_type: "sd4", response_format: "xml", api_endpoint: API_ENDPOINT)
      @api_key = api_key
      @api_type = api_type
      @response_format = response_format
      @api_endpoint = api_endpoint
      @search_cache = MemoryCache
    end

    def url_for(word)
      "#{API_ENDPOINT}/#{api_type}/#{response_format}/#{CGI.escape(word)}?key=#{api_key}"
    end

    def search(term, update_cache: false)
      if search_cache
        if update_cache
          response = fetch_response(term)
          search_cache.remove(term)
          search_cache.add(term, response)
        else
          response = search_cache.find(term)
          unless response
            response = fetch_response(term)
            search_cache.add(term, response)
          end
        end
      else
        response = fetch_response(term)
      end
      Result.new(term, response, api_type:api_type)
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