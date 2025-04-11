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
    option :metrics, aliases: "-m", desc: "Include aggregate metrics in the output", type: :boolean, default: false
    option :max_lag, desc: "Maximum lag in months for currency score calculation", type: :numeric, default: 24
    
    def analyze
      puts "Analyzing gems from #{options[:input]}..."
      
      # Parse the Gemfile.lock
      parser = GemInspector::GemfileParser.new(options[:input])
      gems = parser.parse
      puts "Found #{gems.size} gems in Gemfile.lock" if options[:verbose]
      
      # Analyze the gems
      analyzer = GemInspector::Analyzer.new(options[:active_threshold], options[:max_lag])
      results = analyzer.analyze(gems)
      
      # Calculate metrics if requested
      metrics = nil
      if options[:metrics]
        metrics = analyzer.calculate_metrics(results)
        display_metrics(metrics)
      end
      
      # Export to CSV
      exporter = GemInspector::CsvExporter.new
      output_path = exporter.export(results, options[:output], metrics)
      
      puts "Analysis complete! CSV report saved to: #{output_path}"
    end
    
    desc "metrics", "Calculate aggregate metrics for gems in a Gemfile.lock"
    option :input, aliases: "-i", desc: "Path to Gemfile.lock", default: "Gemfile.lock"
    option :output, aliases: "-o", desc: "Path to output CSV file", default: "gem_metrics_report.csv"
    option :active_threshold, aliases: "-t", desc: "Time threshold in months for 'actively maintained' status", type: :numeric, default: 24
    option :max_lag, desc: "Maximum lag in months for currency score calculation", type: :numeric, default: 24
    option :verbose, aliases: "-v", desc: "Enable verbose logging", type: :boolean, default: false
    
    def metrics
      puts "Calculating metrics for gems in #{options[:input]}..."
      
      # Parse the Gemfile.lock
      parser = GemInspector::GemfileParser.new(options[:input])
      gems = parser.parse
      puts "Found #{gems.size} gems in Gemfile.lock" if options[:verbose]
      
      # Analyze the gems
      analyzer = GemInspector::Analyzer.new(options[:active_threshold], options[:max_lag])
      results = analyzer.analyze(gems)
      
      # Calculate metrics
      metrics = analyzer.calculate_metrics(results)
      display_metrics(metrics)
      
      # Export to CSV if requested
      if options[:output]
        exporter = GemInspector::CsvExporter.new
        output_path = exporter.export(results, options[:output], metrics)
        puts "Metrics report saved to: #{output_path}"
      end
    end
    
    default_task :analyze
    
    private
    
    def display_metrics(metrics)
      puts metrics.to_json # Output metrics as JSON
    end
  end
end