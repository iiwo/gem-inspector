require 'spec_helper'
require 'gem_inspector/rubygems_client'
require 'webmock/rspec'

RSpec.describe GemInspector::RubygemsClient do
  let(:client) { described_class.new }

  before do
    WebMock.disable_net_connect!
  end

  after do
    WebMock.allow_net_connect!
  end

  describe '#fetch_versions' do
    context 'when the gem exists' do
      before do
        stub_request(:get, "https://rubygems.org/api/v1/versions/rails.json")
          .to_return(
            status: 200,
            body: [
              { "number" => "7.0.0", "created_at" => "2023-01-01T00:00:00.000Z", "built_at" => "2023-01-01T00:00:00.000Z", "prerelease" => false },
              { "number" => "6.1.4", "created_at" => "2021-06-24T00:00:00.000Z", "built_at" => "2021-06-24T00:00:00.000Z", "prerelease" => false }
            ].to_json
          )
      end

      it 'returns an array of versions' do
        versions = client.fetch_versions('rails')

        expect(versions).to be_an(Array)
        expect(versions.size).to eq(2)
        expect(versions.first["number"]).to eq("7.0.0")
        expect(versions.last["number"]).to eq("6.1.4")
      end
    end

    context 'when the gem does not exist' do
      before do
        stub_request(:get, "https://rubygems.org/api/v1/versions/nonexistent_gem.json")
          .to_return(status: 404, body: { "error" => "Not found" }.to_json)
      end

      it 'raises an error' do
        expect { client.fetch_versions('nonexistent_gem') }.to raise_error(GemInspector::Error, /Failed to fetch versions/)
      end
    end
  end

  describe '#get_gem_data' do
    context 'when the gem exists' do
      before do
        stub_request(:get, "https://rubygems.org/api/v1/versions/rails.json")
          .to_return(
            status: 200,
            body: [
              { "number" => "7.0.0", "created_at" => "2023-01-01T00:00:00.000Z", "built_at" => "2023-01-01T00:00:00.000Z", "prerelease" => false },
              { "number" => "6.1.4", "created_at" => "2021-06-24T00:00:00.000Z", "built_at" => "2021-06-24T00:00:00.000Z", "prerelease" => false },
              { "number" => "7.0.0.rc1", "created_at" => "2022-12-01T00:00:00.000Z", "built_at" => "2022-12-01T00:00:00.000Z", "prerelease" => true }
            ].to_json
          )
      end

      it 'returns data about the locked version and latest version' do
        data = client.get_gem_data('rails', '6.1.4')

        expect(data).to be_a(Hash)
        expect(data[:locked_version_data]["number"]).to eq("6.1.4")
        expect(data[:latest_version]["number"]).to eq("7.0.0")
      end

      it 'handles prerelease versions correctly' do
        data = client.get_gem_data('rails', '7.0.0.rc1')

        expect(data[:locked_version_data]["number"]).to eq("7.0.0.rc1")
        expect(data[:locked_version_data]["prerelease"]).to eq(true)
        expect(data[:latest_version]["number"]).to eq("7.0.0")
        expect(data[:latest_version]["prerelease"]).to eq(false)
      end
    end
  end
end