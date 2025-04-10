# frozen_string_literal: true

require "httparty"
require "json"
require "time"

module Gem
  module Inspector
    class Enricher
      include HTTParty
      base_uri "https://rubygems.org/api/v1"

      def initialize(gem_data)
        @gem_data = gem_data
      end

      def enrich
        response = self.class.get("/versions/#{@gem_data[:name]}.json")
        return nil unless response.success?

        versions = JSON.parse(response.body)
        enrich_gem_data(versions)
      rescue HTTParty::Error, JSON::ParserError => e
        warn "Error enriching #{@gem_data[:name]}: #{e.message}"
        nil
      end

      private

      def enrich_gem_data(versions)
        stable_versions = versions.reject { |v| v["number"].match?(/[a-zA-Z]/) }
        latest_version = stable_versions.max_by { |v| Time.parse(v["built_at"]) }
        locked_version = versions.find { |v| v["number"] == @gem_data[:version] }

        {
          name: @gem_data[:name],
          locked_version: @gem_data[:version],
          locked_release_date: locked_version&.dig("built_at"),
          latest_version: latest_version["number"],
          latest_release_date: latest_version["built_at"]
        }
      end
    end
  end
end 