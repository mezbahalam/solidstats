# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-05-26

### Added
- **Complete Gem Metadata System**: Comprehensive gem dependency tracking and management
  - Dual-view interface with grid and table layouts
  - Real-time search and filtering by gem name, status, and other criteria
  - Smart sorting by name, status, release date, and version information
  - Status indicators for outdated, up-to-date, and unavailable gems
  - Dependency visualization with runtime dependency details
  - Version comparison showing current vs. latest versions
  - CSV export functionality for gem data analysis
  - Refresh capability to update gem metadata from RubyGems API
  - Responsive design with 3-cards-per-row grid (2 on tablet, 1 on mobile)

- **View Component Architecture**: Modern component-based UI system for maintainable code
  - BaseComponent foundation for all UI components
  - Specialized components for different dashboard sections
  - Component preview system for development and testing
  - Reusable UI components (ActionButton, SummaryCard, Navigation, TabNavigation)
  - Clean separation of concerns between HTML, CSS, and JavaScript

- **Feature Generator System**: Automated development tools for rapid feature development
  - `rails g solidstats:feature` generator for creating new dashboard sections
  - Automatic component, controller, view, and asset generation
  - Built-in best practices and conventions
  - Template-based code generation with customizable options

- **CSS Component Architecture**: Modular styling system with 1,631+ lines of extracted CSS
  - Dedicated component stylesheets for maintainable styling
  - Conflict-free CSS with proper specificity management
  - Responsive design patterns and mobile-first approach
  - Consistent design tokens and reusable style patterns

### Fixed
- **Gem Metadata Table Layout**: Eliminated horizontal scrolling issues
  - Changed table wrapper from `overflow-x: auto` to `width: 100%`
  - Removed restrictive `white-space: nowrap` from table headers
  - Implemented percentage-based column widths for better responsiveness
  - Added proper word-wrapping for long content

- **Empty State Positioning**: Perfect centering for "No matching gems found" messages
  - Implemented flexbox-based centering for both grid and table views
  - Added proper fallback support for older browsers
  - Enhanced visual hierarchy and user experience

- **Navigation System**: Fixed section-based navigation throughout the application
  - Removed external routing in favor of seamless section switching
  - Updated all navigation components to use `data-section` attributes
  - Eliminated page reloads when switching between dashboard sections
  - Consistent navigation behavior across all components

- **CSS Conflicts**: Resolved styling conflicts between component stylesheets
  - Fixed security.css interference with gem metadata styling
  - Implemented proper CSS specificity to prevent style bleeding
  - Added scoped styling for component isolation

### Improved
- **Performance Optimizations**: Enhanced user experience with better responsiveness
  - Debounced search functionality to reduce unnecessary API calls
  - Efficient DOM manipulation and rendering
  - Optimized CSS delivery and reduced file sizes

- **Cross-Browser Compatibility**: Enhanced support for different browsers and devices
  - Fallback CSS for older browser versions
  - Progressive enhancement patterns
  - Improved mobile experience and touch interactions


## [1.1.0] - 2025-05-23

### Added
- Log Size Monitor feature:
  - Comprehensive monitoring of all Rails application log files
  - Total log directory size tracking with status indicators
  - Individual log file monitoring with size and status details
  - Visual indicators for log size status (OK, Warning, Danger)
  - Visual meter showing log size relative to thresholds
  - One-click log truncation for individual files or all logs
  - Sortable log file table with size and last modified information
  - Log management recommendations

### Fixed
- Fixed log file truncation when filename is provided without extension
- Added constraints to route handling to improve filename parameter handling

## [1.0.0] - 2025-05-22

### Added
- Fully functional refresh button with AJAX updates
- Dynamic dashboard refreshing for all components:
  - Security metrics and score update in real-time
  - Vulnerability table regeneration with fresh data
  - Donut chart visualization updates
  - Gem impact analysis section updates
  - Vulnerability details section updates
- Enhanced disabled button tooltips with inline display
- Comprehensive security dashboard features:
  - Security score rating (A+, B, C) based on vulnerabilities
  - Detailed vulnerability table with filtering and searching
  - Visual severity breakdown with interactive donut chart
  - Gem impact analysis with affected gem grouping
  - Detailed vulnerability information with remediation options

### Fixed
- Vulnerability details no longer hidden under sticky header when clicking "More details"
- Improved scroll offset calculations for better navigation
- Added visual feedback with animations when viewing details
- Fixed "Back to vulnerabilities table" button positioning

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

### Added
- Future enhancements will be listed here
