require 'rake'
require 'rake/testtask'

# Define the Rake tasks for the gem-inspector project

# Task to run tests
Rake::TestTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = true
end

# Task to build the gem
task :build do
  sh 'gem build gem-inspector.gemspec'
end

# Task to release the gem
task :release do
  sh 'gem push gem-inspector-*.gem'
end

# Default task
task default: [:test]