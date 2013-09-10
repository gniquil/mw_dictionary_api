require 'spec_helper'

describe MWDictionaryAPI do
  it "returns api end point" do
    expect(MWDictionaryAPI::API_ENDPOINT).to eq 'http://www.dictionaryapi.com/api/v1/references'
  end
end