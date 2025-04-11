require 'date'
require 'gem_inspector/rubygems_client'

module GemInspector
  class Analyzer
    def initialize(active_threshold_months = 24, max_lag_months = 24)
      @active_threshold_months = active_threshold_months
      @max_lag_months = max_lag_months
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
          
          # Calculate gem currency score
          currency_score = calculate_currency_score(locked_release_date, latest_release_date, locked_version, latest_version)
          
          # Calculate lag in months if outdated
          lag_months = if outdated && locked_release_date
                         # Calculate months between release dates
                         ((latest_release_date - locked_release_date) / 30).round
                       else
                         0
                       end
          
          results << {
            gem_name: gem_name,
            locked_version: locked_version,
            locked_release_date: locked_release_date,
            latest_version: latest_version,
            latest_release_date: latest_release_date,
            actively_maintained: actively_maintained,
            outdated: outdated,
            currency_score: currency_score,
            lag_months: lag_months
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
    
    def calculate_metrics(results)
      # Filter out gems with errors
      valid_results = results.reject { |r| r[:error] }
      total_gems = valid_results.size
      return {} if total_gems == 0
      
      # Calculate outdated gems ratio
      outdated_gems = valid_results.count { |r| r[:outdated] }
      outdated_ratio = (outdated_gems.to_f / total_gems) * 100
      
      # Calculate gem currency score
      total_score = valid_results.sum { |r| r[:currency_score] || 0 }
      avg_currency_score = total_score.to_f / total_gems # Ensure full precision during division
      
      {
        total_gems: total_gems,
        outdated_gems: outdated_gems,
        outdated_gems_ratio: outdated_ratio.round(2), # Reintroduced rounding for outdated_gems_ratio
        gem_currency_score: avg_currency_score.round(2) # Reintroduced rounding for gem_currency_score to match test expectations
      }
    end
    
    private
    
    def calculate_currency_score(locked_release_date, latest_release_date, locked_version, latest_version)
      # If versions are the same or we don't have release dates, the gem is up to date
      return 100 if Gem::Version.new(locked_version) >= Gem::Version.new(latest_version)
      return 100 if locked_release_date.nil? || latest_release_date.nil?
      
      # Calculate lag in months
      lag_months = ((latest_release_date - locked_release_date) / 30).round
      
      # Apply the score formula: 100 * (1 - lag/max_lag)
      # If lag >= max_lag, score is 0
      return 0 if lag_months >= @max_lag_months
      
      # Otherwise, calculate proportional score
      (100 * (1 - lag_months.to_f / @max_lag_months)) # Removed rounding
    end
  end
end