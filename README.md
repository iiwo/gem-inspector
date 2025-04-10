# Gem Inspector

A Ruby gem that analyzes your Gemfile.lock dependencies and generates a report about their maintenance status and version information.

## Features

- Parses Gemfile.lock to extract dependency information
- Queries RubyGems.org API for version metadata
- Determines if gems are outdated
- Checks if gems are actively maintained based on a configurable threshold
- Generates a CSV report with detailed information

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

The gem provides a command-line interface to analyze your Gemfile.lock and generate a report:

```bash
$ gem-inspector analyze --input Gemfile.lock --output report.csv --active-threshold 24
```

### Options

- `--input, -i`: Path to your Gemfile.lock (required)
- `--output, -o`: Path for the output CSV file (default: gem_inspector_report.csv)
- `--active-threshold, -t`: Maintenance threshold in months (default: 24)

### Example

Suppose you have a Rails application and want to check if its dependencies are up-to-date and actively maintained. Simply run:

```bash
$ cd /path/to/rails/app
$ gem-inspector analyze -i Gemfile.lock -o gems_report.csv
```

This will generate a CSV report `gems_report.csv` containing information about all your dependencies. If you open this file, you'll see something like:

```
Gem Name,Locked Version,Locked Release Date,Latest Version,Latest Release Date,Actively Maintained,Outdated
rails,6.1.4.1,2021-08-19T00:00:00.000Z,7.0.4,2022-11-08T00:00:00.000Z,yes,yes
puma,5.5.2,2021-10-12T00:00:00.000Z,6.0.0,2022-10-08T00:00:00.000Z,yes,yes
sqlite3,1.4.2,2019-12-18T00:00:00.000Z,1.5.4,2022-11-18T00:00:00.000Z,yes,yes
webpacker,5.4.3,2021-09-30T00:00:00.000Z,5.4.3,2021-09-30T00:00:00.000Z,no,no
```

From this report, you can quickly identify gems that are outdated (like `rails` and `puma`) and gems that might not be actively maintained (like `webpacker`).

### Output

The generated CSV report includes the following columns:

- Gem Name
- Locked Version
- Locked Release Date
- Latest Version
- Latest Release Date
- Actively Maintained (yes/no)
- Outdated (yes/no)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/gem-inspector. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/yourusername/gem-inspector/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Gem Inspector project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/yourusername/gem-inspector/blob/master/CODE_OF_CONDUCT.md). 