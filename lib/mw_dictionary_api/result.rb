module MWDictionaryAPI
  class Result
    
    attr_reader :raw_doc, :searched_word, :entries

    def initialize(searched_word, raw_doc)
      @searched_word = searched_word
      @raw_doc = raw_doc
      parse
    end

    def parse
      xml_doc = Nokogiri::XML(raw_doc)
      
      xml_doc.css("entry").each do |xml_entry|
        id_attribute = xml_entry.attribute("id").value
        word, word_index = Result.parse_word_and_index(id_attribute)
        unless entries.has_key? word
          entries[word] = [Entry.new(word, xml_entry, word_index)]
        else
          entries[word] << Entry.new(word, xml_entry, word_index)
        end
      end

      self
    end

    def entries
      @entries ||= {}
    end

    def entries_as_array
      @entries.values.flatten
    end

    def self.parse_word_and_index(id_attribute)
      id_attribute_array = id_attribute.split(/\[|\]/)
      if id_attribute_array.count == 2
        [id_attribute_array[0], id_attribute_array[1].to_i]
      elsif id_attribute_array.count == 1
        [id_attribute_array[0], 1]
      else
        raise ArgumentError, "Invalid id attribute in entry node"
      end
    end
  end
end