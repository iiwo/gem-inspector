# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gem::Inspector::CLI do
  let(:cli) { described_class.new }
  let(:fixture_path) { "spec/fixtures/Gemfile.lock" }
  let(:output_path) { "spec/fixtures/output.csv" }

  describe "#analyze" do
    before do
      # Mock the API responses for each gem in the fixture
      %w[actionpack actionview activesupport builder concurrent-ruby erubi httparty i18n loofah mime-types mime-types-data minitest multi_xml nokogiri racc rack rack-test rails-dom-testing rails-html-sanitizer thor tzinfo].each do |gem_name|
        api_url = "https://rubygems.org/api/v1/versions/#{gem_name}.json"
        stub_request(:get, api_url)
          .to_return(
            status: 200,
            body: [
              { "number" => "0.1.0", "built_at" => "2020-01-01T00:00:00.000Z" },
              { "number" => "0.2.0", "built_at" => "2023-01-01T00:00:00.000Z" }
            ].to_json
          )
      end

      # Allow exporter to create file
      allow_any_instance_of(Gem::Inspector::Exporter).to receive(:export).and_return(true)
      allow(cli).to receive(:say)
    end

    after do
      File.delete(output_path) if File.exist?(output_path)
    end

    it "runs the analyze process with provided options" do
      expect {
        cli.options = { input: fixture_path, output: output_path, active_threshold: 12 }
        cli.analyze
      }.not_to raise_error
    end

    it "handles errors gracefully" do
      allow_any_instance_of(Gem::Inspector::Parser).to receive(:parse).and_raise(StandardError.new("Test error"))
      
      expect {
        cli.options = { input: fixture_path, output: output_path }
        cli.analyze
      }.to raise_error(SystemExit)
    end
  end
end 