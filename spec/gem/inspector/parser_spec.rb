# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gem::Inspector::Parser do
  let(:parser) { described_class.new("spec/fixtures/Gemfile.lock") }

  describe "#parse" do
    it "extracts gem names and versions from Gemfile.lock" do
      gems = parser.parse
      expect(gems).to be_an(Array)
      expect(gems.first).to include(:name, :version)
    end
  end
end 