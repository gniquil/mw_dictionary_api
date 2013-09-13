# encoding: UTF-8

module MWDictionaryAPI
  module Parsers
    class DefinitionParser
      include Parsable

      rule :sense_number do |data, opts|
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

      rule :text do |data, opts|
        dt_without_vi = data[:dt].dup
        dt_without_vi.css("vi").remove
        dt_without_vi.content.strip
      end

      rule :verbal_illustration do |data, opts|
        data[:dt].at_css("vi").content if data[:dt].at_css("vi")
      end

      rule :cross_reference do |data, opts|
        data[:dt].xpath("sx").inject([]) do |xrefs, sx|
          xrefs << sx.content
        end
      end
    end
  end
end