module MWDictionaryAPI

  class Entry

    attr_reader :id_attribute, :id, :word, :head_word, 
                :pronunciation, :part_of_speech, :sound, 
                :definitions, :inflections,
                :api_type

    def initialize(xml_doc, api_type: "sd4")
      @xml_doc = xml_doc
      @api_type = api_type

      @id_attribute = @xml_doc.attribute("id").value

      @word, @id = parse_word_and_index

      @head_word = parse_tag("hw")
      @pronunciation = parse_tag("pr")
      @part_of_speech = parse_tag("fl")
      @sound = parse_tag("sound wav")

      @definitions = parse_definitions

      @inflections = parse_inflections
    end

    def to_hash
      {
        "word" => word,
        "id" => id,
        "head_word" => head_word,
        "pronunciation" => pronunciation,
        "part_of_speech" => part_of_speech,
        "inflections" => inflections.to_hash,
        "definitions" => definitions.map { |d| d.to_hash }
      }
    end

    def parse_tag(tag)
      @xml_doc.at_css(tag).content if @xml_doc.at_css(tag)
    end

    def parse_word_and_index
      m = /(.*)\[(\d+)\]/.match(@id_attribute)
      (m) ? [m[1], m[2].to_i] : [@id_attribute, 1]
    end

    def parse_definitions
      # here we assume 
      # 1. sense number (sn) alway appear before a definition (dt) in pairs
      # 2. definition (dt) appear by itself
      # @xml_doc.xpath("//entry[@id='#{@id_attribute}']//sn | //entry[@id='#{@id_attribute}']//dt").each_slice(2) do |nodes|
      @xml_doc.xpath("def//sn | def//dt").each_slice(2).inject([]) do |definitions, nodes|
        hash = Hash[nodes.map {|n| n.name.to_sym}.zip(nodes.map {|n| (n.name == 'sn') ? n.content : n })]
        if hash.has_key? :dt 
          hash[:prev_sn] = definitions[-1].sense_number if definitions[-1]
          definitions << Definition.new(**hash, api_type: api_type)
        end
        definitions
      end
    end

    def parse_inflections
      @xml_doc.xpath("in//il | in//if").each_slice(2).inject([]) do |hashes, nodes|
        hash = Hash[nodes.map {|n| n.name.to_sym}.zip(nodes.map {|n| n.content})]
        hash[:il] = hashes[-1][:il] if hash[:il] == "or"
        hashes << hash
        hashes
      end.inject({}) do |inflections, hash|
        inflections[hash[:il]] ||= []
        inflections[hash[:il]] << hash[:if].gsub(/\W/, "")
        inflections
      end
    end
  end
end