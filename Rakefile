# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Run RuboCop"
task :rubocop do
  require "rubocop/rake_task"
  RuboCop::RakeTask.new
end

desc "Run all tests and checks"
task :test do
  Rake::Task["spec"].invoke
  Rake::Task["rubocop"].invoke
end 