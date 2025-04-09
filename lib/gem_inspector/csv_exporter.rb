require 'csv'

module GemInspector
  class CsvExporter
    # Export gem data to a CSV file
    #
    # @param gems [Array<Hash>] Array of gem data hashes
    # @param output_path [String] Path to the output CSV file
    # @return [void]
    def self.export(gems, output_path)
      headers = [
        "Gem Name",
        "Locked Version",
        "Locked Release Date",
        "Latest Version",
        "Latest Release Date",
        "Actively Maintained",
        "Outdated"
      ]
      
      begin
        CSV.open(output_path, "w", write_headers: true, headers: headers) do |csv|
          gems.each do |gem|
            csv << [
              gem[:name],
              gem[:locked_version],
              gem[:locked_release_date],
              gem[:latest_version],
              gem[:latest_release_date],
              gem[:actively_maintained],
              gem[:outdated]
            ]
          end
        end
      rescue => e
        raise Error, "Error writing CSV file: #{e.message}"
      end
    end
  end
end
