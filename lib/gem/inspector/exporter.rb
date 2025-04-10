# frozen_string_literal: true

require "csv"

module Gem
  module Inspector
    class Exporter
      def initialize(analyzed_data, output_path)
        @analyzed_data = analyzed_data
        @output_path = output_path
      end

      def export
        CSV.open(@output_path, "w") do |csv|
          csv << headers
          @analyzed_data.each do |data|
            csv << format_row(data)
          end
        end
      end

      private

      def headers
        %w[
          Gem\ Name
          Locked\ Version
          Locked\ Release\ Date
          Latest\ Version
          Latest\ Release\ Date
          Actively\ Maintained
          Outdated
        ]
      end

      def format_row(data)
        [
          data[:name],
          data[:locked_version],
          data[:locked_release_date],
          data[:latest_version],
          data[:latest_release_date],
          data[:actively_maintained] ? "yes" : "no",
          data[:outdated] ? "yes" : "no"
        ]
      end
    end
  end
end 