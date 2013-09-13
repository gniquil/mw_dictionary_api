# require 'active_support/core_ext/class/attribute'
require 'nokogiri'
require 'mw_dictionary_api/client'
require 'mw_dictionary_api/result'
require "mw_dictionary_api/parsable"
require 'mw_dictionary_api/memory_cache'
require 'mw_dictionary_api/parsers/entry_parser'
require 'mw_dictionary_api/parsers/result_parser'
require 'mw_dictionary_api/parsers/definition_parser'

module MWDictionaryAPI
  API_ENDPOINT = 'http://www.dictionaryapi.com/api/v1/references'

  class ResponseException < Exception
  end

end