# encoding: UTF-8

require 'spec_helper'

module MWDictionaryAPI
  module Parsers
    describe ResultParser do
      let(:word) { "one" }
      let(:raw_response) { File.open(fixture_path("one.xml")).read }
      let(:attributes) { ResultParser.new.parse(Nokogiri::XML(raw_response)) }
      let(:invalid_raw_response) { File.open(fixture_path("onet.xml")).read }
      let(:invalid_attributes) { ResultParser.new.parse(Nokogiri::XML(invalid_raw_response)) }

      it "returns a list of entries" do
        expected_keys = [
          'one',
          'one',
          'one',
          'one another',
          'one-dimensional',
          'one-horse',
          'one-man',
          'one-on-one',
          'one-piece',
          'one-sided'
        ]
        attributes[:entries].each_index do |index|
          expect(attributes[:entries][index][:word]).to eq expected_keys[index]
        end
      end

      it "should return a list of suggestions if the word is invalid" do
        expect(invalid_attributes[:entries]).to be_empty
        expect(invalid_attributes[:suggestions].count).to be > 0
      end

      it "should return empty suggestions if the word is valid" do
        expect(attributes[:suggestions]).to be_empty
      end
    end
  end
end