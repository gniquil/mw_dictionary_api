
RSpec.configure do |config|
  config.around(:each) do |example|
    MWDictionaryAPI::Client.API_KEY = ENV["MW_API_KEY"]
    example.run
    MWDictionaryAPI::Client.API_KEY = ENV["MW_API_KEY"]
  end
end