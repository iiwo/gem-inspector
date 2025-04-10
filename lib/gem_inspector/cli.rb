require 'thor'
require 'gem_inspector/gemfile_parser'
require 'gem_inspector/analyzer'
require 'gem_inspector/csv_exporter'

module GemInspector
  class CLI < Thor
    desc "analyze", "Analyze gems in a Gemfile.lock"
    option :input, aliases: "-i", desc: "Path to Gemfile.lock", default: "Gemfile.lock"
    option :output, aliases: "-o", desc: "Path to output CSV file", default: "gem_inspector_report.csv"
    option :active_threshold, aliases: "-t", desc: "Time threshold in months for 'actively maintained' status", type: :numeric, default: 24
    option :verbose, aliases: "-v", desc: "Enable verbose logging", type: :boolean, default: false
    
    def analyze
      puts "Analyzing gems from #{options[:input]}..."
      
      # Parse the Gemfile.lock
      parser = GemInspector::GemfileParser.new(options[:input])
      gems = parser.parse
      puts "Found #{gems.size} gems in Gemfile.lock" if options[:verbose]
      
      # Analyze the gems
      analyzer = GemInspector::Analyzer.new(options[:active_threshold])
      results = analyzer.analyze(gems)
      
      # Export to CSV
      exporter = GemInspector::CsvExporter.new
      output_path = exporter.export(results, options[:output])
      
      puts "Analysis complete! CSV report saved to: #{output_path}"
    end
    
    default_task :analyze
  end
end