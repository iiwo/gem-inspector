# frozen_string_literal: true

require "spec_helper"
require "csv"
require "tempfile"

RSpec.describe Gem::Inspector::Exporter do
  let(:analyzed_data) do
    [
      {
        name: "httparty",
        locked_version: "0.20.0",
        locked_release_date: "2022-01-01T00:00:00.000Z",
        latest_version: "0.21.0",
        latest_release_date: "2023-01-01T00:00:00.000Z",
        outdated: true,
        actively_maintained: true
      },
      {
        name: "thor",
        locked_version: "1.2.1",
        locked_release_date: "2022-02-01T00:00:00.000Z",
        latest_version: "1.2.1",
        latest_release_date: "2022-02-01T00:00:00.000Z",
        outdated: false,
        actively_maintained: true
      }
    ]
  end

  describe "#export" do
    it "creates a CSV file with the correct headers and data" do
      tempfile = Tempfile.new(["export", ".csv"])
      exporter = described_class.new(analyzed_data, tempfile.path)
      exporter.export

      csv_data = CSV.read(tempfile.path, headers: true)
      expect(csv_data.headers).to eq(
        ["Gem Name", "Locked Version", "Locked Release Date", 
         "Latest Version", "Latest Release Date", 
         "Actively Maintained", "Outdated"]
      )

      expect(csv_data.size).to eq(2)
      
      first_row = csv_data[0]
      expect(first_row["Gem Name"]).to eq("httparty")
      expect(first_row["Locked Version"]).to eq("0.20.0")
      expect(first_row["Latest Version"]).to eq("0.21.0")
      expect(first_row["Actively Maintained"]).to eq("yes")
      expect(first_row["Outdated"]).to eq("yes")

      second_row = csv_data[1]
      expect(second_row["Gem Name"]).to eq("thor")
      expect(second_row["Outdated"]).to eq("no")
    end
  end
end 