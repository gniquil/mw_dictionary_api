module MWDictionaryAPI
  class Result
    
    attr_reader :raw_response, :api_type, :term, :entries, :suggestions

    def initialize(term, raw_response, api_type: "sd4")
      unless %W[collegiate sd4].include? api_type
        raise ArgumentError, "Not a supported api_type"
      end

      @term = term
      @raw_response = raw_response
      @api_type = api_type

      @entries = parse(raw_response, api_type)
      @suggestions = parse_suggestions(raw_response, api_type)
    end

    def parse(raw_response, api_type)
      entries = []
      xml_doc = Nokogiri::XML(raw_response)
      
      xml_doc.css("entry").each do |xml_entry|
        entries << Entry.new(xml_entry, api_type: api_type)
      end
      entries
    end

    def parse_suggestions(raw_response, api_type)
      suggestions = []
      xml_doc = Nokogiri::XML(raw_response)

      xml_doc.css("suggestion").each do |suggestion_xml|
        suggestions << suggestion_xml.content
      end
      suggestions
    end

    def entries_group_by_word
      entries.group_by { |entry| entry.word }
    end

    def to_hash
      {
        "term" => term,
        "entries" => entries.map { |e| e.to_hash }
      }
    end
  end
end