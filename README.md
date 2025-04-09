# Gem Inspector

Gem Inspector is a Ruby gem that analyzes your Gemfile.lock file to provide insights about your dependencies. It checks each gem's locked version against the latest available version on RubyGems.org and determines whether the gem is actively maintained.

## Features

- Parses Gemfile.lock files to extract gem names and versions
- Queries the RubyGems.org API for version metadata
- Determines if gems are outdated compared to their latest versions
- Checks if gems are actively maintained based on their latest release date
- Exports results to a CSV report with detailed information

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gem-inspector'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install gem-inspector
```

## Usage

### Command Line

The basic usage is:

```bash
$ gem-inspector --input Gemfile.lock --output report.csv
```

#### Options

- `--input`, `-i`: Path to the Gemfile.lock file (required)
- `--output`, `-o`: Path for the output CSV report (default: gem_inspector_report.csv)
- `--active-threshold`, `-t`: Time threshold in months for "actively maintained" status (default: 24)
- `--verbose`, `-v`: Enable verbose logging

### Example

```bash
$ gem-inspector --input Gemfile.lock --output gem_report.csv --active-threshold 12 --verbose
```

This will:
1. Parse the Gemfile.lock file
2. Query RubyGems.org for each gem's version information
3. Generate a CSV report with columns for:
   - Gem Name
   - Locked Version
   - Locked Release Date
   - Latest Version
   - Latest Release Date
   - Actively Maintained (yes/no)
   - Outdated (yes/no)

## CSV Report Format

The generated CSV report includes the following columns:

| Column | Description |
|--------|-------------|
| Gem Name | Name of the gem |
| Locked Version | Version specified in your Gemfile.lock |
| Locked Release Date | Release date of the locked version |
| Latest Version | Latest stable version available on RubyGems.org |
| Latest Release Date | Release date of the latest version |
| Actively Maintained | "yes" if the latest release is within the threshold, "no" otherwise |
| Outdated | "yes" if the locked version is older than the latest version, "no" otherwise |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/gem-inspector.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
