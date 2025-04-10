require 'spec_helper'
require 'gem_inspector/gemfile_parser'

RSpec.describe GemInspector::GemfileParser do
  let(:fixture_path) { 'spec/fixtures/Gemfile.lock' }
  let(:parser) { described_class.new(fixture_path) }

  describe '#parse' do
    context 'with a valid Gemfile.lock' do
      it 'extracts gem names and their locked versions' do
        gems = parser.parse
        
        expect(gems).to be_a(Hash)
        expect(gems).to include('rails', 'nokogiri')
        expect(gems['rails']).to match(/\d+\.\d+\.\d+/)
        expect(gems['nokogiri']).to match(/\d+\.\d+\.\d+/)
      end
    end

    context 'with a non-existent Gemfile.lock' do
      let(:parser) { described_class.new('non-existent-file.lock') }
      
      it 'raises an error' do
        expect { parser.parse }.to raise_error(GemInspector::Error, /not found/)
      end
    end
  end
end