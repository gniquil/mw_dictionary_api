module MWDictionaryAPI

  class Entry

    attr_reader :word, :id
    attr_reader :head_word, :pronunciation, :part_of_speech, :sound, :definitions, :inflections

    def initialize(word, xml_doc, id)
      @word = word
      @id = id
      @xml_doc = xml_doc

      set_instance_var_by_tag(:head_word, "hw")
      set_instance_var_by_tag(:pronunciation, "pr")
      set_instance_var_by_tag(:part_of_speech, "fl")
      set_instance_var_by_tag(:sound, "sound wav")

      @definitions = []
      
      parse_definitions

      @inflections = {}

      parse_inflections
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

    private

    def set_instance_var_by_tag(varname, tag)
      tag_entity = @xml_doc.at_css(tag)
      if tag_entity
        instance_variable_set("@#{varname.to_s}", tag_entity.content)
      else
        instance_variable_set("@#{varname.to_s}", nil)
      end
    end

    def parse_definitions
      temp = []
      @xml_doc.css("def").children.each do |child|
        temp << child
        if child.name == "dt"
          if temp.count == 2
            definitions << Definition.new(self, dt: temp[1], sn: temp[0].content)
          else
            definitions << Definition.new(self, dt: temp[0])
          end
          temp = []
        end
      end
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

      @inflections = temp.inject({}) do |memo, obj|
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