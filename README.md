Solidstats is a local-only Rails engine that shows your project's health at `/solidstats`. The dashboard provides real-time insights into your application's security, code quality, and development tasks.

## Features
- Interactive security dashboard with real-time refresh capability
- Comprehensive gem vulnerability analysis with severity breakdown
- Visual security score rating (A+, B, C) and metrics
- Bundler Audit scan with detailed remediation suggestions
- Interactive vulnerability details with patched version information
- Gem impact analysis showing affected gems by severity
- Log Size Monitor for tracking and managing application log files
- Log file truncation tool for individual or all log files
- Rubocop offense count and quality metrics
- TODO/FIXME tracker with file hotspots
- Test coverage summary

## Compatibility

- Ruby 2.7+: Compatible with Rails 6.1 through Rails 7.0
- Ruby 3.0-3.1: Compatible with Rails 6.1 through Rails 7.x
- Ruby 3.2+: Compatible with all Rails 6.1+ versions

Solidstats automatically detects your Ruby version and selects a compatible Rails version.

### CI/Testing

This gem is automatically tested across multiple Ruby versions (2.7, 3.0, 3.1, and 3.2) to ensure compatibility. If you're contributing to this gem, make sure your changes work across all supported Ruby versions.

## Installation

```ruby
# Gemfile (dev only)
group :development do
  gem 'solidstats'
end
```

After bundle install, you can run the installer:

```bash
bundle exec rails g solidstats:install
```

Or using the provided rake task:

```bash
bundle exec rake solidstats:install
```

The installer will automatically mount the engine in your routes:

```ruby
# config/routes.rb
mount Solidstats::Engine => '/solidstats' if Rails.env.development?
```

## Usage

Visit `/solidstats` in your development environment to access the dashboard. The dashboard provides an overview of your application's health and is organized into the following sections:

### Overview
Shows summary cards for security issues, TODO items, and code quality metrics.

### Security
Provides a comprehensive security dashboard with:
- Security score rating based on vulnerability severity
- Vulnerability metrics showing critical, high, medium and low issues
- Interactive vulnerability table with filtering and searching
- Gem impact analysis showing which gems are affected
- Detailed vulnerability information with remediation suggestions

You can refresh the dashboard data at any time by clicking the "Refresh" button in the top navigation bar. This will:
1. Trigger a fresh security audit of your application
2. Update all metrics and visualizations with current data
3. Show real-time feedback during the refresh process
4. Update the "Last Updated" timestamp

### Code Quality
Displays code quality metrics, test coverage, and code health indicators.

### Tasks
Shows a breakdown of TODO, FIXME, and HACK annotations found in your codebase, with file hotspots and expandable details.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/infolily/solidstats.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
