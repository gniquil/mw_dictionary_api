module MWDictionaryAPI

  class Entry

    attr_reader :id_attribute, :id, :word, :head_word, 
                :pronunciation, :part_of_speech, :sound, 
                :definitions, :inflections,
                :api_type, :response_format

    def initialize(xml_doc, api_type: "sd4", response_format: "xml")
      @xml_doc = xml_doc
      @api_type = api_type
      @response_format = response_format

      parser = Parsers::EntryParser.new(api_type: api_type, response_format: response_format)
      attributes = parser.parse(xml_doc)

      @id_attribute = attributes[:id_attribute]
      @word = attributes[:word]
      @id = attributes[:id]
      @head_word = attributes[:head_word]
      @pronunciation = attributes[:pronunciation]
      @part_of_speech = attributes[:part_of_speech]
      @sound = attributes[:sound]
      @definitions = attributes[:definitions]
      @inflections = attributes[:inflections]
    end

    def to_hash
      {
        "id" => id,
        "word" => word,
        "head_word" => head_word,
        "pronunciation" => pronunciation,
        "part_of_speech" => part_of_speech,
        "inflections" => inflections,
        "definitions" => definitions
      }
    end

  end
end