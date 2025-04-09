begin
  require 'bundler'
  BUNDLER_AVAILABLE = true
rescue LoadError
  BUNDLER_AVAILABLE = false
end

module GemInspector
  class Parser
    # Parse a Gemfile.lock file and extract gem names and versions
    #
    # @param file_path [String] Path to the Gemfile.lock file
    # @return [Array<Hash>] Array of hashes with :name and :version keys
    def self.parse(file_path)
      unless File.exist?(file_path)
        raise Error, "Gemfile.lock not found at #{file_path}"
      end

      if BUNDLER_AVAILABLE
        parse_with_bundler(file_path)
      else
        parse_manually(file_path)
      end
    end

    private

    def self.parse_with_bundler(file_path)
      begin
        lockfile_content = File.read(file_path)
        parser = Bundler::LockfileParser.new(lockfile_content)

        # Extract gem specs from the lockfile
        gems = parser.specs.map do |spec|
          {
            name: spec.name,
            version: spec.version.to_s
          }
        end

        gems
      rescue Bundler::LockfileError => e
        raise Error, "Invalid Gemfile.lock format: #{e.message}"
      rescue => e
        raise Error, "Error parsing Gemfile.lock: #{e.message}"
      end
    end

    def self.parse_manually(file_path)
      begin
        content = File.read(file_path)
        gems = []
        in_specs_section = false

        content.each_line do |line|
          if line.strip == "GEM"
            in_specs_section = true
            next
          end

          if in_specs_section && line.strip == ""
            in_specs_section = false
            next
          end

          if in_specs_section && line.strip.start_with?("specs:")
            next
          end

          if in_specs_section && line.match(/^\s{4}\S+\s\(\S+\)$/)
            parts = line.strip.match(/^(\S+)\s\((\S+)\)$/)
            if parts
              gems << {
                name: parts[1],
                version: parts[2]
              }
            end
          end
        end

        gems
      rescue => e
        raise Error, "Error parsing Gemfile.lock: #{e.message}"
      end
    end
  end
end
