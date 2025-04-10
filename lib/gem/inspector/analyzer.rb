# frozen_string_literal: true

require "rubygems"

module Gem
  module Inspector
    class Analyzer
      def initialize(enriched_data, maintenance_threshold_months: 24)
        @enriched_data = enriched_data
        @maintenance_threshold = maintenance_threshold_months * 30 * 24 * 60 * 60 # Convert to seconds
      end

      def analyze
        return nil unless @enriched_data

        {
          **@enriched_data,
          outdated: outdated?,
          actively_maintained: actively_maintained?
        }
      end

      private

      def outdated?
        return false unless @enriched_data[:locked_version] && @enriched_data[:latest_version]

        Gem::Version.new(@enriched_data[:locked_version]) <
          Gem::Version.new(@enriched_data[:latest_version])
      end

      def actively_maintained?
        return false unless @enriched_data[:latest_release_date]

        latest_release = Time.parse(@enriched_data[:latest_release_date])
        (Time.now - latest_release) <= @maintenance_threshold
      end
    end
  end
end 