module MWDictionaryAPI

  class Entry

    attr_reader :id, :word, :head_word, 
                :pronunciation, :part_of_speech, :sound, 
                :definitions, :inflections

    def initialize(xml_doc)
      @xml_doc = xml_doc

      @word, @id = parse_word_and_index(@xml_doc.attribute("id").value)

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
      (@xml_doc.at_css(tag)) ? @xml_doc.at_css(tag).content : nil
    end

    def parse_word_and_index(id_attribute)
      id_attribute_array = id_attribute.split(/\[|\]/)
      if id_attribute_array.count == 2
        [id_attribute_array[0], id_attribute_array[1].to_i]
      elsif id_attribute_array.count == 1
        [id_attribute_array[0], 1]
      else
        raise ArgumentError, "Invalid id attribute in entry node"
      end
    end

    def parse_definitions
      definitions = []
      temp = []

      @xml_doc.css("def").children.each do |child|
        if ["sn", "dt"].include? child.name
          temp << child
          if child.name == "dt"
            prev_sn = (definitions[-1]) ? definitions[-1].sense_number : nil
            if temp.count == 2
              definitions << Definition.new(dt: temp[1], sn: temp[0].content, prev_sn: prev_sn)
            else
              definitions << Definition.new(dt: temp[0], prev_sn: prev_sn)
            end
            temp = []
          end
        end
      end

      definitions
    end

    def parse_inflections
      temp = []
      il_array = @xml_doc.css("in il").map { |il| il.content }
      iff_array = @xml_doc.css("in if").map { |iff| iff.content.gsub(/\W/, "") }

      il_array.each_index do |index|
        if il_array[index] == "or"
          temp << { label: il_array[index-1], value: iff_array[index] }
        else  
          temp << { label: il_array[index], value: iff_array[index] }
        end
      end

      temp.inject({}) do |memo, obj|
        il = obj[:label]
        if memo.has_key? il
          memo[il] << obj[:value]
        else
          memo[il] = [obj[:value]]
        end
        memo
      end
    end
  end
end