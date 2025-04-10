# frozen_string_literal: true

require "thor"
require "gem/inspector"

module Gem
  module Inspector
    class CLI < Thor
      desc "analyze", "Analyze Gemfile.lock and generate report"
      option :input, aliases: "-i", required: true, desc: "Path to Gemfile.lock"
      option :output, aliases: "-o", default: "gem_inspector_report.csv", desc: "Output CSV file path"
      option :active_threshold, aliases: "-t", type: :numeric, default: 24, desc: "Maintenance threshold in months"

      def analyze
        parser = Parser.new(options[:input])
        gems = parser.parse

        analyzed_data = gems.map do |gem_data|
          enriched_data = Enricher.new(gem_data).enrich
          next unless enriched_data

          Analyzer.new(enriched_data, maintenance_threshold_months: options[:active_threshold]).analyze
        end.compact

        Exporter.new(analyzed_data, options[:output]).export
        say "Report generated successfully at #{options[:output]}", :green
      rescue StandardError => e
        say "Error: #{e.message}", :red
        exit 1
      end

      def self.exit_on_failure?
        true
      end
    end
  end
end 