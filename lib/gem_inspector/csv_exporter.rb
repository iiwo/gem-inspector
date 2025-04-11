require 'csv'

module GemInspector
  class CsvExporter
    def export(data, output_path, metrics = nil)
      CSV.open(output_path, "wb") do |csv|
        # Write metrics at the top if provided
        if metrics && !metrics.empty?
          csv << ["Gem Metrics Summary"]
          csv << ["Total Gems", metrics[:total_gems].to_s]
          csv << ["Outdated Gems", metrics[:outdated_gems].to_s]
          csv << ["Outdated Gems Ratio (%)", metrics[:outdated_gems_ratio].to_s]
          csv << ["Overall Gem Currency Score", metrics[:gem_currency_score].to_s]
          csv << [] # Empty row as separator
        end
        
        # Write headers
        csv << ["Gem Name", "Locked Version", "Locked Release Date", "Latest Version", 
                "Latest Release Date", "Actively Maintained", "Outdated", "Currency Score", "Lag (months)"]
        
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
            gem_data[:outdated] ? "yes" : "no",
            gem_data[:currency_score],
            gem_data[:lag_months]
          ]
        end
      end
      
      output_path
    end
  end
end