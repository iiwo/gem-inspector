# gem-inspector/gem-inspector/README.md

# gem-inspector

## Overview

`gem-inspector` is a Ruby gem designed to analyze gem dependencies specified in a `Gemfile.lock` file. It retrieves version metadata from RubyGems.org and generates a comprehensive report on the status of each gem, including whether it is outdated or actively maintained.

## Features

- Parses `Gemfile.lock` to extract gem names and their locked versions.
- Queries RubyGems.org API for version metadata.
- Identifies the latest stable version and its release date.
- Compares locked versions with the latest versions to determine if gems are outdated.
- Applies a configurable maintenance threshold to assess if gems are actively maintained.
- Exports results to a CSV report.

## Installation

To install the gem, add the following line to your application's Gemfile:

```ruby
gem 'gem-inspector'
```

Then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install gem-inspector
```

## Usage

To use `gem-inspector`, run the following command in your terminal:

```bash
gem-inspector --input Gemfile.lock --output report.csv --active-threshold 24
```

### Command-Line Options

- `--input` or `-i`: Path to the `Gemfile.lock` file.
- `--output` or `-o`: Path and filename for the CSV report (default: `gem_inspector_report.csv`).
- `--active-threshold` or `-t`: Time threshold in months for determining "actively maintained" status (default: 24).
- `--verbose` or `-v`: Enable verbose logging for debugging.

## Example

```bash
gem-inspector --input Gemfile.lock --output report.csv --active-threshold 12
```

This command will analyze the specified `Gemfile.lock`, check the status of each gem, and generate a report in `report.csv`.

## Contributing

1. Fork it ( https://github.com/yourusername/gem-inspector/fork )
2. Create your feature branch (git checkout -b feature/new-feature)
3. Commit your changes (git commit -m 'Add some feature')
4. Push to the branch (git push origin feature/new-feature)
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.