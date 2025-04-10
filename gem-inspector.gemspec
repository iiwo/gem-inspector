Gem::Specification.new do |spec|
  spec.name          = "gem-inspector"
  spec.version       = "0.1.0"
  spec.authors       = ["Your Name"]
  spec.email         = ["your.email@example.com"]
  spec.summary       = "A Ruby gem to analyze gem dependencies and their statuses."
  spec.description   = "This gem reads and parses a Gemfile.lock file, queries RubyGems.org for version metadata, and exports the results as a CSV report."
  spec.homepage      = "https://github.com/yourusername/gem-inspector"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb"] + Dir["exe/*"] + ["README.md"]
  spec.bindir        = "exe"
  spec.executables   = ["gem-inspector"]
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty"
  spec.add_dependency "csv"
  spec.add_dependency "bundler"
end