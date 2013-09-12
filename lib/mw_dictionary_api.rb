# require 'active_support/core_ext/class/attribute'
require 'nokogiri'
require 'mw_dictionary_api/client'
require 'mw_dictionary_api/result'
require 'mw_dictionary_api/entry'
require 'mw_dictionary_api/definition'
require "mw_dictionary_api/parsable"
require 'mw_dictionary_api/entry_parser'
require 'mw_dictionary_api/result_parser'
require 'mw_dictionary_api/definition_parser'
require 'mw_dictionary_api/memory_cache'

module MWDictionaryAPI
  API_ENDPOINT = 'http://www.dictionaryapi.com/api/v1/references'

  class ResponseException < Exception
  end

end