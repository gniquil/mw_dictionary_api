# encoding: UTF-8

module MWDictionaryAPI
  module Parsers
    class EntryParser
      include Parsable

      rule :id_attribute do |data, opts|
        data.attribute("id").value
      end

      rule :head_word do |data, opts|
        parse_entity(data, "hw")
      end

      rule :pronunciation do |data, opts|
        parse_entity(data, "pr")
      end

      rule :part_of_speech do |data, opts|
        parse_entity(data, "fl")
      end

      rule :sound do |data, opts|
        parse_entity(data, "sound wav")
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
        data.xpath("def//sn | def//dt").each_slice(2).inject([]) do |definitions, nodes|
          hash = Hash[nodes.map {|n| n.name.to_sym}.zip(nodes.map {|n| (n.name == 'sn') ? n.content : n })]
          hash[:prev_sn] = definitions[-1][:sense_number] if definitions[-1]
          definitions << DefinitionParser.new(parser_options(opts)).parse(hash)
        end  
      end

      rule :inflections do |data, opts|
        inflections = data.xpath("in").inject([]) do |inflections, in_node|
          hash = {}
          in_node.xpath("il | if").each do |node|
            if node.name == "il"
              hash[:inflection_label] = node.content
            else
              hash[:inflected_form] = node.content.gsub(/\W/, "").force_encoding("UTF-8")
            end

            if hash.has_key? :inflected_form
              inflections << hash
              hash = {}
            end
          end
          inflections
        end
        inflections.each_index do |index|
          if inflections[index][:inflection_label] == "or"
            inflections[index][:inflection_label] = inflections[index-1][:inflection_label] if index > 0
          end
        end
        inflections
      end

      rule_helpers do
        def parser_options(opts)
          { api_type: opts[:api_type], response_format: opts[:response_format] }
        end

        def parse_entity(data, tag)
          data.at_css(tag).content if data.at_css(tag)
        end
      end
    end
  end
end