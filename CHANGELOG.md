# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.4] - 2025-05-20

### Added
- Service-based architecture for data collection with caching
- Base DataCollectorService class for shared functionality
- Specialized services: AuditService and TodoService
- Comprehensive UI/UX redesign with modern dashboard layout:
  - Sticky navigation menu with intuitive section links
  - Organized dashboard sections (Overview, Security, Code Quality, Tasks)
  - Tabbed interfaces for better content organization
  - Interactive summary cards with click-to-navigate functionality
- Enhanced security visualization:
  - Visual security score indicator (A+, B, C ratings) with color coding
  - Improved vulnerability metrics display with severity breakdown
  - Detailed vulnerability table with filtering and search capabilities
  - New "Affected Gems" tab with visual cards for vulnerable dependencies
  - Timeline visualization for security history
- Improved code quality section:
  - Dedicated tabs for Metrics, Test Coverage, and Code Health
  - Visual progress bars for test coverage
- Task management improvements:
  - Organized tabs for TODOs, FIXMEs, and HACKs
  - Better categorization and display of code tasks
- Responsive layout adjustments for various screen sizes
- Quick floating navigation menu for easy section access
- Toast notification system for user feedback

### Fixed
- Ruby version compatibility issues with dependency constraints
- Support for multiple Ruby versions (2.7+, 3.0+, 3.2+)
- Automatic Rails version selection based on Ruby version (6.1 through 8.x)
- Documentation of compatibility matrix in README
- Variable scope issues in nested template partials
- Consistent passing of data between dashboard partials

## [0.0.3] - 2025-05-20

### Added
- Install generator (`rails g solidstats:install`) to automatically mount routes
- Rake task (`rake solidstats:install`) as an alias for the generator
- Improved documentation for installation process

## [0.0.2] - 2025-05-19

### Added
- Asset precompilation configuration for solidstats/application.css in development environment

## [0.0.1] - 2025-05-19

### Added
- Initial release of the Solidstats gem
- Basic engine structure
- Development mode restriction
- Dashboard controller with initial views
- Security audit components and views

## [Unreleased]

- Improved TODO dashboard partial:
  - Ensured correct handling of nil keys in the hotspots hash.
  - Displayed TODO, FIXME, and HACK counts with color-coded badges.
  - Added expandable details for files with most TODOs and all TODO items.
  - Enhanced UI with better grouping and error handling for TODO data.
