# frozen_string_literal: true

require "spec_helper"
require "time"

RSpec.describe Gem::Inspector::Analyzer do
  let(:now) { Time.now }
  let(:one_month_ago) { (now - 30 * 24 * 60 * 60).iso8601 }
  let(:three_years_ago) { (now - 3 * 365 * 24 * 60 * 60).iso8601 }

  describe "#analyze" do
    context "when the gem is outdated" do
      let(:enriched_data) do
        {
          name: "httparty",
          locked_version: "0.20.0",
          locked_release_date: three_years_ago,
          latest_version: "0.21.0",
          latest_release_date: one_month_ago
        }
      end

      it "marks the gem as outdated and actively maintained" do
        analyzer = described_class.new(enriched_data)
        result = analyzer.analyze

        expect(result[:outdated]).to be true
        expect(result[:actively_maintained]).to be true
      end
    end

    context "when the gem is up to date" do
      let(:enriched_data) do
        {
          name: "httparty",
          locked_version: "0.21.0",
          locked_release_date: one_month_ago,
          latest_version: "0.21.0",
          latest_release_date: one_month_ago
        }
      end

      it "marks the gem as not outdated but actively maintained" do
        analyzer = described_class.new(enriched_data)
        result = analyzer.analyze

        expect(result[:outdated]).to be false
        expect(result[:actively_maintained]).to be true
      end
    end

    context "when the gem is not actively maintained" do
      let(:enriched_data) do
        {
          name: "httparty",
          locked_version: "0.20.0",
          locked_release_date: three_years_ago,
          latest_version: "0.21.0",
          latest_release_date: three_years_ago
        }
      end

      it "marks the gem as outdated and not actively maintained" do
        analyzer = described_class.new(enriched_data)
        result = analyzer.analyze

        expect(result[:outdated]).to be true
        expect(result[:actively_maintained]).to be false
      end
    end

    context "with a custom maintenance threshold" do
      let(:enriched_data) do
        {
          name: "httparty",
          locked_version: "0.20.0",
          locked_release_date: three_years_ago,
          latest_version: "0.21.0",
          latest_release_date: three_years_ago
        }
      end

      it "applies the custom threshold for maintenance status" do
        # Set threshold to 4 years, so the 3-year-old gem is still maintained
        analyzer = described_class.new(enriched_data, maintenance_threshold_months: 48)
        result = analyzer.analyze

        expect(result[:actively_maintained]).to be true
      end
    end
  end
end 