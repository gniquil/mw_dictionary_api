# encoding: UTF-8
require 'ostruct'

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
        nodes = data.xpath("def//sn | def//dt")
        sd = nil

        # first step we will add dummy nodes if the list of nodes is not
        # strictly sn/dt pairs
        nodes = add_dummy_nodes(nodes)

        # data.xpath("def//sn | def//dt")
        nodes.each_slice(2).inject([]) do |definitions, nodes|
          names = nodes.map { |n| n.name.to_sym }
          values = nodes.map do |node|
            if node.content
              (node.name == 'sn') ? node.content : node
            else
              nil
            end
          end
          hash = Hash[names.zip(values)]
          hash[:prev_sn] = definitions[-1][:sense_number] if definitions[-1]
          hash[:sense_divider] = sd if sd = previous_sense_divider(nodes[1])
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

      rule :undefined_run_ons do |data, opts|
        data.xpath("uro").inject([]) do |uros, uro_node|
          hash = {}
          hash[:entry]          = parse_entity(uro_node, "ure")
          hash[:sound]          = parse_entity(uro_node, "sound wav")
          hash[:pronunciation]  = parse_entity(uro_node, "pr")
          hash[:part_of_speech] = parse_entity(uro_node, "fl")

          uros << hash
        end
      end

      rule_helpers do
        def parser_options(opts)
          { api_type: opts[:api_type], response_format: opts[:response_format] }
        end

        def parse_entity(data, tag)
          data.at_css(tag).content if data.at_css(tag)
        end

        def previous_sense_divider(node)
          if node.previous_element && node.previous_element.name == 'sd'
            node.previous_element
          else
            nil
          end
        end

        def add_dummy_nodes(nodes)
          temp = []
          previous_sense_number = nil
          nodes.each do |node|
            if temp.count == 0
              if node.name != 'sn'
                temp << OpenStruct.new(name: 'sn', content: '0')
                previous_sense_number = '0'
              else
                previous_sense_number = node.content
              end
              temp << node
            else
              if temp[-1].name == 'sn'
                if node.name == 'sn'
                  temp << OpenStruct.new(name: 'dt', content: '')
                  previous_sense_number = node.content
                end
                temp << node
              else
                if node.name == 'dt'
                  temp << OpenStruct.new(name: 'sn', content: previous_sense_number)
                else
                  previous_sense_number = node.content
                end
                temp << node
              end
            end
          end
          temp
        end
      end
    end
  end
end
