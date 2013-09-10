require 'cgi'
require 'open-uri'

module MWDictionaryAPI
  class Client
    
    attr_reader :api_key, :api_type, :api_endpoint, :response_format

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
    end

    def url_for(word)
      "#{API_ENDPOINT}/#{api_type}/#{response_format}/#{CGI.escape(word)}?key=#{api_key}"
    end

    def search(term, update_cache: false)
      if search_cache
        search_cache.remove(term) if update_cache
        response = search_cache.find(term)
        unless response
          response = fetch_response(term)
          search_cache.add(term, response)
        end
      else
        response = fetch_response(term)
      end
      Result.new(term, response, api_type)
    end

    def fetch_response(term)
      open(url_for(term)).read
    end
  end
end