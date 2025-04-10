require 'httparty'
require 'json'

module GemInspector
  class RubygemsClient
    def initialize
      @base_url = "https://rubygems.org/api/v1"
    end

    def fetch_versions(gem_name)
      response = HTTParty.get("#{@base_url}/versions/#{gem_name}.json")
      
      if response.code == 200
        JSON.parse(response.body)
      else
        raise GemInspector::Error, "Failed to fetch versions for #{gem_name}: HTTP #{response.code}"
      end
    end

    def get_gem_data(gem_name, locked_version)
      versions = fetch_versions(gem_name)
      
      # Filter out prerelease versions
      stable_versions = versions.reject { |v| v["prerelease"] }
      
      # Find the locked version data
      locked_version_data = versions.find { |v| v["number"] == locked_version }
      
      # Find the latest stable version
      latest_version = stable_versions.max_by { |v| v["built_at"] ? Time.parse(v["built_at"]) : Time.new(0) }
      
      {
        locked_version_data: locked_version_data,
        latest_version: latest_version
      }
    end
  end
end