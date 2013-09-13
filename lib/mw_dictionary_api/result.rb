# encoding: UTF-8

module MWDictionaryAPI
  class Result
    
    attr_reader :raw_response, :api_type, :response_format, :term, 
                :entries, :suggestions

    def initialize(term, raw_response, api_type: "sd4", response_format: "xml")
      unless %W[collegiate sd4].include? api_type
        raise ArgumentError, "Not a supported api_type"
      end

      @term = term
      @raw_response = raw_response
      @api_type = api_type
      @response_format = response_format

      parser = Parsers::ResultParser.new(api_type: api_type, response_format: response_format)
      attributes = parser.parse(Nokogiri::XML(raw_response))
      @entries = attributes[:entries]
      @suggestions = attributes[:suggestions]
    end

    def to_hash
      {
        "term" => term,
        "entries" => entries.map { |e| e.to_hash },
        "suggestions" => suggestions.map { |s| s.to_hash }
      }
    end
  end
end