lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gem_inspector/version"

Gem::Specification.new do |spec|
  spec.name          = "gem-inspector"
  spec.version       = GemInspector::VERSION
  spec.authors       = ["Your Name"]
  spec.email         = ["your.email@example.com"]

  spec.summary       = %q{Analyzes Gemfile.lock to report on gem versions and maintenance status}
  spec.description   = %q{A Ruby gem that parses Gemfile.lock files, queries RubyGems.org API for version information, and generates a CSV report with details about gem versions, release dates, and maintenance status.}
  spec.homepage      = "https://github.com/yourusername/gem-inspector"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # Specify which files should be added to the gem when it is released.
  spec.files         = Dir.glob("{bin,lib}/**/*") + %w[LICENSE.txt README.md]
  spec.bindir        = "exe"
  spec.executables   = ["gem-inspector"]
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", "~> 0.21.0"
  spec.add_dependency "thor", "~> 1.2"
  spec.add_dependency "csv", "~> 3.2"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.18"
  spec.add_development_dependency "vcr", "~> 6.1"
end
