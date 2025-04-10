require 'date'
require 'gem_inspector/rubygems_client'

module GemInspector
  class Analyzer
    def initialize(active_threshold_months = 24)
      @active_threshold_months = active_threshold_months
      @client = GemInspector::RubygemsClient.new
    end

    def analyze(gems)
      results = []
      
      gems.each do |gem_name, locked_version|
        begin
          gem_data = @client.get_gem_data(gem_name, locked_version)
          
          locked_release_date = gem_data[:locked_version_data] ? 
                              Date.parse(gem_data[:locked_version_data]["built_at"]) : nil
          latest_version = gem_data[:latest_version]["number"]
          latest_release_date = Date.parse(gem_data[:latest_version]["built_at"])
          
          # Determine if outdated (locked < latest)
          outdated = Gem::Version.new(locked_version) < Gem::Version.new(latest_version)
          
          # Determine if actively maintained
          threshold_date = Date.today << @active_threshold_months # Subtract months
          actively_maintained = latest_release_date >= threshold_date
          
          results << {
            gem_name: gem_name,
            locked_version: locked_version,
            locked_release_date: locked_release_date,
            latest_version: latest_version,
            latest_release_date: latest_release_date,
            actively_maintained: actively_maintained,
            outdated: outdated
          }
        rescue => e
          warn "Error analyzing gem #{gem_name}: #{e.message}"
          # Add the gem with error information
          results << {
            gem_name: gem_name,
            locked_version: locked_version,
            error: e.message
          }
        end
      end
      
      results
    end
  end
end