# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gem::Inspector::Enricher do
  let(:gem_data) { { name: "httparty", version: "0.20.0" } }
  let(:enricher) { described_class.new(gem_data) }

  describe "#enrich" do
    let(:api_url) { "https://rubygems.org/api/v1/versions/httparty.json" }
    let(:api_response) do
      [
        {
          "number" => "0.21.0",
          "built_at" => "2023-01-01T00:00:00.000Z"
        },
        {
          "number" => "0.20.0",
          "built_at" => "2022-01-01T00:00:00.000Z"
        },
        {
          "number" => "0.19.0",
          "built_at" => "2021-01-01T00:00:00.000Z"
        }
      ]
    end

    before do
      stub_request(:get, api_url)
        .to_return(status: 200, body: api_response.to_json)
    end

    it "enriches gem data with version information" do
      result = enricher.enrich
      expect(result).to include(
        name: "httparty",
        locked_version: "0.20.0",
        locked_release_date: "2022-01-01T00:00:00.000Z",
        latest_version: "0.21.0",
        latest_release_date: "2023-01-01T00:00:00.000Z"
      )
    end

    context "when API request fails" do
      before do
        stub_request(:get, api_url).to_return(status: 500)
      end

      it "returns nil" do
        expect(enricher.enrich).to be_nil
      end
    end
  end
end 