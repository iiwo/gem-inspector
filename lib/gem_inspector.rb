require 'gem_inspector/version'
require 'gem_inspector/gemfile_parser'
require 'gem_inspector/rubygems_client'
require 'gem_inspector/analyzer'
require 'gem_inspector/csv_exporter'
require 'gem_inspector/cli'

module GemInspector
  class Error < StandardError; end
  # Your code goes here...
end