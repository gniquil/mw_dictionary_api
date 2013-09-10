module MWDictionaryAPI
  class Result
    
    attr_reader :raw_response, :api_type, :searched_word, :entries

    def initialize(searched_word, raw_response, api_type)
      unless %W[collegiate sd4].include? api_type
        raise ArgumentError, "Not a supported api_type"
      end

      @searched_word = searched_word
      @raw_response = raw_response
      @api_type = api_type

      @entries = parse(raw_response, api_type)
    end

    def parse(raw_response, api_type)
      entries = []
      xml_doc = Nokogiri::XML(raw_response)
      
      xml_doc.css("entry").each do |xml_entry|
        entries << Entry.new(xml_entry)
      end
      entries
    end

    def entries_group_by_word
      entries.group_by { |entry| entry.word }
    end

  end
end