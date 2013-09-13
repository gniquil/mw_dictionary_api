
RSpec.configure do |config|
  config.before(:each) do
    MWDictionaryAPI::Client.cache = MWDictionaryAPI::MemoryCache
    MWDictionaryAPI::Client.cache.clear
    MWDictionaryAPI::Client.parser_class = MWDictionaryAPI::Parsers::ResultParser
  end
end