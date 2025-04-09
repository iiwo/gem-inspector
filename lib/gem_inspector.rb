require "gem_inspector/version"
require "gem_inspector/parser"
require "gem_inspector/api_client"
require "gem_inspector/analyzer"
require "gem_inspector/csv_exporter"
require "gem_inspector/cli"

module GemInspector
  class Error < StandardError; end
  
  # Main entry point for the gem
  def self.run(options)
    # Parse the Gemfile.lock
    gems = Parser.parse(options[:input])
    
    # Enrich with data from RubyGems.org
    enriched_gems = gems.map do |gem|
      begin
        gem_data = ApiClient.fetch_gem_data(gem[:name])
        Analyzer.analyze(
          gem[:name], 
          gem[:version], 
          gem_data, 
          options[:active_threshold]
        )
      rescue => e
        puts "Error processing gem #{gem[:name]}: #{e.message}" if options[:verbose]
        # Return partial data for the gem with error flags
        {
          name: gem[:name],
          locked_version: gem[:version],
          locked_release_date: nil,
          latest_version: nil,
          latest_release_date: nil,
          actively_maintained: "unknown",
          outdated: "unknown",
          error: e.message
        }
      end
    end
    
    # Export to CSV
    CsvExporter.export(enriched_gems, options[:output])
    
    puts "Report generated successfully: #{options[:output]}"
  end
end
