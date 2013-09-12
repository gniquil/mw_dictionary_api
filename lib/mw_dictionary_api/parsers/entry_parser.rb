module MWDictionaryAPI
  module Parsers
    class EntryParser
      include Parsable

      rule :id_attribute do |data, opts|
        data.attribute("id").value
      end

      rule :head_word do |data, opts|
        data.at_css("hw").content if data.at_css("hw")
      end

      rule :pronunciation do |data, opts|
        data.at_css("pr").content if data.at_css("pr")
      end

      rule :part_of_speech do |data, opts|
        data.at_css("fl").content if data.at_css("fl")
      end

      rule :sound do |data, opts|
        data.at_css("sound wav").content if data.at_css("sound wav")
      end

      rule :word do |data, opts|
        id_attribute = data.attribute("id").value
        m = /(.*)\[(\d+)\]/.match(id_attribute)
        (m) ? m[1] : id_attribute
      end

      rule :id do |data, opts|
        id_attribute = data.attribute("id").value
        m = /(.*)\[(\d+)\]/.match(id_attribute)
        (m) ? m[2].to_i : 1
      end

      rule :definitions do |data, opts|
        # here we assume 
        # 1. sense number (sn) alway appear before a definition (dt) in pairs
        # 2. definition (dt) appear by itself
        # @xml_doc.xpath("//entry[@id='#{@id_attribute}']//sn | //entry[@id='#{@id_attribute}']//dt").each_slice(2) do |nodes|
        data.xpath("def//sn | def//dt").each_slice(2).inject([]) do |definitions, nodes|
          hash = Hash[nodes.map {|n| n.name.to_sym}.zip(nodes.map {|n| (n.name == 'sn') ? n.content : n })]
          hash[:prev_sn] = definitions[-1]["sense_number"] if definitions[-1]
          definitions << {
            "sense_number" => apply_rule(:def_sense_number, hash, opts),
            "cross_reference" => apply_rule(:def_cross_reference, hash, opts),
            "verbal_illustration" => apply_rule(:def_verbal_illustration, hash, opts),
            "text" => apply_rule(:def_text, hash, opts)
          }
        end  
      end

      rule :def_sense_number, hidden: true do |data, opts|
        current_sn = (data[:sn] or "1")
        previous_sn = data[:prev_sn]

        current_sn = current_sn.gsub(" ", "")

        if previous_sn.nil?
          current_sn
        else
          if current_sn =~ /^\d+/ # starts with a digit
            current_sn
          elsif current_sn =~ /^[a-z]+/ # starts with a alphabet
            m = /^(\d+)/.match(previous_sn)
            (m) ? m[1] + current_sn : current_sn
          else # starts with a bracket ( e.g. (1)
            m = /^(\d+)*([a-z]+)*/.match(previous_sn)
            m[1..2].select { |segment| !segment.nil? }.join("") + current_sn
          end
        end
      end

      rule :def_text, hidden: true do |data, opts|
        dt_without_vi = data[:dt].dup
        dt_without_vi.css("vi").remove
        dt_without_vi.content.strip
      end

      rule :def_verbal_illustration, hidden: true do |data, opts|
        data[:dt].at_css("vi").content if data[:dt].at_css("vi")
      end

      rule :def_cross_reference, hidden: true do |data, opts|
        data[:dt].xpath("sx").inject([]) do |xrefs, sx|
          xrefs << sx.content
        end
      end

      rule :inflections do |data, opts|
        data.xpath("in//il | in//if").each_slice(2).inject([]) do |hashes, nodes|
          hash = Hash[nodes.map {|n| n.name.to_sym}.zip(nodes.map {|n| n.content})]
          hash[:il] = hashes[-1][:il] if hash[:il] == "or"
          hashes << hash
        end.inject({}) do |inflections, hash|
          inflections[hash[:il]] ||= []
          inflections[hash[:il]] << hash[:if].gsub(/\W/, "")
          inflections
        end
      end
    end
  end
end