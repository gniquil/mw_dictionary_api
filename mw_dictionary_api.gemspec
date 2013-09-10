Gem::Specification.new do |s|
  s.name        = 'mw_dictionary_api'
  s.version     = '0.0.1'
  s.date        = '2013-09-07'
  s.summary     = "Merriam Webster Dictionary API"
  s.description = "A Simple Way to Query Merriam Webster Dictionary API"
  s.authors     = ["Frank Liu"]
  s.email       = 'gniquil@gmail.com'
  s.files       = [
    "lib/mw_dictionary_api.rb", 
    "lib/mw_dictionary_api/client.rb",
    "lib/mw_dictionary_api/result.rb",
    "lib/mw_dictionary_api/entry.rb",
    "lib/mw_dictionary_api/definition.rb"
  ]
  s.homepage    = 'https://github.com/gniquil/mw_dictionary_api'
  s.license       = 'MIT'
  s.add_runtime_dependency "nokogiri"
end