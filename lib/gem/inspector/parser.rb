# frozen_string_literal: true

require "bundler"
require "bundler/lockfile_parser"

module Gem
  module Inspector
    class Parser
      def initialize(file_path)
        @file_path = file_path
      end

      def parse
        lockfile = Bundler::LockfileParser.new(Bundler.read_file(@file_path))
        extract_gems(lockfile)
      end

      private

      def extract_gems(lockfile)
        lockfile.specs.map do |spec|
          {
            name: spec.name,
            version: spec.version.to_s
          }
        end
      end
    end
  end
end 