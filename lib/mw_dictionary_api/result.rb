# encoding: UTF-8

require 'nokogiri'
require 'json'

module MWDictionaryAPI
  class Result
    
    attr_accessor :parser_class
    attr_reader :term, :raw_response, :api_type, :response_format,
                :entries, :suggestions

    def initialize(term, raw_response, api_type: "sd4", response_format: "xml", parser_class: Parsers::ResultParser)
      @term = term
      @raw_response = raw_response
      @api_type = api_type
      @response_format = response_format
      @parser_class = parser_class

      parse!
    end

    def parse!
      parser = parser_class.new(api_type: api_type, response_format: response_format)
      attributes = parser.parse(Nokogiri::XML(raw_response))
      @entries = attributes[:entries]
      @suggestions = attributes[:suggestions]
    end

    def to_hash
      {
        term: term,
        entries: entries,
        suggestions: suggestions
      }
    end

    def to_json
      to_hash.to_json
    end
  end
end