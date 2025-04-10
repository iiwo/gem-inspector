require 'csv'

module GemInspector
  class CsvExporter
    def export(data, output_path)
      CSV.open(output_path, "wb") do |csv|
        # Write headers
        csv << ["Gem Name", "Locked Version", "Locked Release Date", "Latest Version", 
                "Latest Release Date", "Actively Maintained", "Outdated"]
        
        # Write data rows
        data.each do |gem_data|
          next if gem_data[:error] # Skip entries with errors
          
          csv << [
            gem_data[:gem_name],
            gem_data[:locked_version],
            gem_data[:locked_release_date],
            gem_data[:latest_version],
            gem_data[:latest_release_date],
            gem_data[:actively_maintained] ? "yes" : "no",
            gem_data[:outdated] ? "yes" : "no"
          ]
        end
      end
      
      output_path
    end
  end
end