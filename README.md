Solidstats is a local-only Rails engine that shows your project's health at `/solidstats`. The dashboard provides real-time insights into your application's security, code quality, and development tasks.

## Features

### Core Dashboard
- Interactive security dashboard with real-time refresh capability
- Comprehensive gem vulnerability analysis with severity breakdown
- Visual security score rating (A+, B, C) and metrics
- Bundler Audit scan with detailed remediation suggestions
- Interactive vulnerability details with patched version information
- Gem impact analysis showing affected gems by severity

### Gem Metadata System
- **Complete Gem Analysis Platform**: Comprehensive gem metadata dashboard with detailed information about all gems in your project
- **Dual-View System**: Switch between table and grid layouts for optimal data presentation
  - **Table View**: Sortable columns with gem name, version, description, dependencies, and status
  - **Grid View**: Card-based layout with 3 cards per row (responsive: 3 on desktop, 2 on tablet, 1 on mobile)
- **Advanced Filtering**: Real-time search and filtering across all gem attributes
- **Dependency Analysis**: View gem dependencies with version compatibility information
- **Status Monitoring**: Real-time health indicators and gem status tracking
- **Download Statistics**: Popularity metrics and download statistics for gems
- **License Information**: Security compliance and license tracking

### System Monitoring
- Log Size Monitor for tracking and managing application log files
- Log file truncation tool for individual or all log files
- LoadLens - Development performance monitoring with request tracking
- Rubocop offense count and quality metrics
- TODO/FIXME tracker with file hotspots
- Test coverage summary

### Architecture
- **View Component Architecture**: Modern, maintainable component-based UI system
- **Feature Generator System**: Automated scaffolding for rapid development
- **CSS Component Architecture**: Organized, conflict-free styling with responsive design
- **Cross-Browser Compatibility**: Enhanced support across modern browsers

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

### Gem Metadata
Comprehensive gem analysis and management platform featuring:
- **Complete Gem Information**: Detailed metadata for all gems in your project including versions, descriptions, dependencies, and status
- **Flexible Views**: 
  - **Table View**: Sortable table with comprehensive gem information, perfect for detailed analysis
  - **Grid View**: Card-based layout showing 3 gems per row with visual appeal and responsive design
- **Advanced Search & Filtering**: Real-time filtering across gem names, descriptions, and dependencies
- **Dependency Analysis**: View and analyze gem dependencies with version information
- **Status Monitoring**: Health indicators and status tracking for all gems
- **Download Metrics**: Popularity statistics and download information
- **License Tracking**: Security compliance and license information for each gem

### Code Quality
Displays code quality metrics, test coverage, and code health indicators.

### LoadLens Performance
Monitors your Rails app's performance in development by parsing `log/development.log`:
- **Response Times**: Average response time across all requests
- **Database Performance**: ActiveRecord query timing analysis  
- **View Rendering**: Template rendering performance metrics
- **Error Tracking**: HTTP status code analysis and error rates
- **Slow Request Detection**: Identifies requests taking >1000ms
- **Request History**: Recent request details with timing breakdown

LoadLens automatically tracks performance data and provides manual refresh capability. Data is stored in daily rotating JSON files and cleaned up after 7 days.

**CLI Commands:**
```bash
# Parse development logs manually
rake solidstats:load_lens:parse_logs

# Refresh performance data
rake solidstats:load_lens:refresh

# View performance summary
rake solidstats:load_lens:summary

# Clean old data files
rake solidstats:load_lens:clean_old_data
```

### Tasks
Shows a breakdown of TODO, FIXME, and HACK annotations found in your codebase, with file hotspots and expandable details.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/infolily/solidstats.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
