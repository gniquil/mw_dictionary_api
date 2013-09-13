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
        data.xpath("in//il | in//if").each_slice(2).inject([]) do |hashes, nodes|
          hash = Hash[nodes.map {|n| n.name.to_sym}.zip(nodes.map {|n| n.content})]
          hash[:il] = hashes[-1][:il] if hashes[-1] and hash[:il] == "or"
          hashes << hash
        end.inject({}) do |inflections, hash|
          inflections[hash[:il].to_sym] ||= []
          inflections[hash[:il].to_sym] << hash[:if].gsub(/\W/, "")
          inflections
        end
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