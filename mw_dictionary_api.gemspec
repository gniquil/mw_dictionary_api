Gem::Specification.new do |s|
  s.name        = 'mw_dictionary_api'
  s.version     = '0.1.2'
  s.date        = '2013-09-07'
  s.summary     = "Merriam Webster Dictionary API"
  s.description = "A Simple Way to Query Merriam Webster Dictionary API"
  s.authors     = ["Frank Liu"]
  s.email       = 'gniquil@gmail.com'
  s.files       = [
    "lib/mw_dictionary_api.rb", 
    "lib/mw_dictionary_api/client.rb",
    "lib/mw_dictionary_api/memory_cache.rb",
    "lib/mw_dictionary_api/parsable.rb",
    "lib/mw_dictionary_api/result.rb",
    "lib/mw_dictionary_api/parsers/result_parser.rb",
    "lib/mw_dictionary_api/parsers/entry_parser.rb",
    "lib/mw_dictionary_api/parsers/definition_parser.rb"
  ]
  s.homepage    = 'https://github.com/gniquil/mw_dictionary_api'
  s.license       = 'MIT'
  s.add_runtime_dependency "nokogiri", "~> 1.6.0"
  s.add_development_dependency "rspec", "~> 2.14.1"
end