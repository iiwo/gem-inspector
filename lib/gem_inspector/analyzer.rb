require 'date'

module GemInspector
  class Analyzer
    # Analyze gem data to determine maintenance status and version information
    #
    # @param gem_name [String] Name of the gem
    # @param locked_version [String] Locked version from Gemfile.lock
    # @param gem_data [Array<Hash>] Version data from RubyGems.org API
    # @param active_threshold [Integer] Threshold in months for "actively maintained" status
    # @return [Hash] Analysis results
    def self.analyze(gem_name, locked_version, gem_data, active_threshold)
      # Filter out prerelease versions
      stable_versions = gem_data.reject { |v| v['prerelease'] }

      # Find the latest stable version
      latest_version_data = stable_versions.max_by { |v| Date.parse(v['built_at']) rescue Date.new(1970, 1, 1) }

      # Find the locked version
      locked_version_data = gem_data.find { |v| v['number'] == locked_version }

      # Prepare result hash
      result = {
        name: gem_name,
        locked_version: locked_version,
        locked_release_date: locked_version_data ? (Date.parse(locked_version_data['built_at']) rescue nil) : nil,
        latest_version: latest_version_data ? latest_version_data['number'] : nil,
        latest_release_date: latest_version_data ? (Date.parse(latest_version_data['built_at']) rescue nil) : nil
      }

      # Determine if the gem is outdated
      if result[:locked_version] && result[:latest_version]
        begin
          result[:outdated] = Gem::Version.new(result[:locked_version]) < Gem::Version.new(result[:latest_version]) ? "yes" : "no"
        rescue
          result[:outdated] = "unknown"
        end
      else
        result[:outdated] = "unknown"
      end

      # Determine if the gem is actively maintained
      if result[:latest_release_date]
        threshold_date = Date.today << active_threshold # Subtract months
        result[:actively_maintained] = result[:latest_release_date] >= threshold_date ? "yes" : "no"
      else
        result[:actively_maintained] = "unknown"
      end

      result
    end
  end
end
