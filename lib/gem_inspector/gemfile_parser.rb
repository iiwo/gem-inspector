require 'bundler'

module GemInspector
  class GemfileParser
    def initialize(lockfile_path)
      @lockfile_path = lockfile_path
    end

    def parse
      validate_file_existence
      lockfile = Bundler::LockfileParser.new(File.read(@lockfile_path))
      
      gems = {}
      lockfile.specs.each do |spec|
        gems[spec.name] = spec.version.to_s
      end
      
      gems
    end

    private

    def validate_file_existence
      raise GemInspector::Error, "Gemfile.lock not found at #{@lockfile_path}" unless File.exist?(@lockfile_path)
    end
  end
end