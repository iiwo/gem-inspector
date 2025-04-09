begin
  require 'thor'
  THOR_AVAILABLE = true
rescue LoadError
  require 'optparse'
  THOR_AVAILABLE = false
end

module GemInspector
  if THOR_AVAILABLE
    class CLI < Thor
      default_task :inspect

      desc "inspect", "Analyze a Gemfile.lock and generate a CSV report"
      method_option :input, aliases: "-i", type: :string, required: true,
                    desc: "Path to the Gemfile.lock file"
      method_option :output, aliases: "-o", type: :string, default: "gem_inspector_report.csv",
                    desc: "Path for the output CSV report"
      method_option :active_threshold, aliases: "-t", type: :numeric, default: 24,
                    desc: "Time threshold in months for 'actively maintained' status"
      method_option :verbose, aliases: "-v", type: :boolean, default: false,
                    desc: "Enable verbose logging"

      def inspect
        begin
          GemInspector.run(options)
        rescue Error => e
          puts "Error: #{e.message}"
          exit 1
        end
      end

      def self.exit_on_failure?
        true
      end
    end
  else
    class CLI
      def self.start(args)
        options = {
          output: "gem_inspector_report.csv",
          active_threshold: 24,
          verbose: false
        }

        parser = OptionParser.new do |opts|
          opts.banner = "Usage: gem-inspector [options]"

          opts.on("-i", "--input PATH", "Path to the Gemfile.lock file") do |path|
            options[:input] = path
          end

          opts.on("-o", "--output PATH", "Path for the output CSV report") do |path|
            options[:output] = path
          end

          opts.on("-t", "--active-threshold MONTHS", Integer, "Time threshold in months for 'actively maintained' status") do |months|
            options[:active_threshold] = months
          end

          opts.on("-v", "--verbose", "Enable verbose logging") do
            options[:verbose] = true
          end

          opts.on("-h", "--help", "Show this help message") do
            puts opts
            exit
          end
        end

        begin
          parser.parse!(args)

          if options[:input].nil?
            puts "Error: --input option is required"
            puts parser
            exit 1
          end

          GemInspector.run(options)
        rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
          puts "Error: #{e.message}"
          puts parser
          exit 1
        rescue Error => e
          puts "Error: #{e.message}"
          exit 1
        end
      end
    end
  end
end
