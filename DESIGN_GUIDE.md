# Solidstats Development Design Guide

## Executive Summary

This guide establishes development standards and architectural patterns for the Solidstats Rails gem. It defines consistent approaches for building new features, maintaining code quality, and ensuring a cohesive user experience across all dashboard components.

**Key Principles:**
- **Consistency**: All features follow standardized patterns established by the feature generator
- **Modularity**: Components are self-contained and reusable
- **Performance**: Efficient data collection with intelligent caching
- **Testability**: Comprehensive test coverage for all generated code
- **User Experience**: Responsive design with consistent visual patterns

## Development Standards

### Feature Development Workflow

All new features **MUST** be created using the standardized feature generator:

```bash
rails generate solidstats:feature FEATURE_NAME [options]
```

This ensures:
- Consistent file structure and naming conventions
- Standardized service patterns with caching
- Uniform helper module architecture
- Complete test coverage
- Proper dashboard integration

### Architecture Patterns

#### 1. Service Layer Pattern
**Location**: `app/services/solidstats/`

Every feature requires a service class that follows this structure:

```ruby
module Solidstats
  class FeatureNameService
    CACHE_KEY = "solidstats_feature_name".freeze
    CACHE_HOURS = 1

    def initialize
      @cache_file = Rails.root.join("tmp", "#{CACHE_KEY}.json")
    end

    # Public API methods
    def fetch(force_refresh = false)    # Main data fetching
    def summary                         # Dashboard summary data
    def detailed_view                   # Full feature data

    private
    # Implementation methods
    def collect_data                    # Data collection logic
    def cache_data(data)               # Caching implementation
    def cached_data                    # Cache retrieval
    def cache_expired?                 # Cache validation
  end
end
```

**Required Methods:**
- `fetch(force_refresh = false)`: Main data retrieval with caching
- `summary`: Returns standardized hash for dashboard cards
- `collect_data`: Private method containing core data collection logic

**Standard Return Format:**
```ruby
{
  value: "Primary display value",
  status: :good | :warning | :critical | :info,
  last_updated: Time.current,
  count: Integer,
  details: Hash  # Feature-specific data
}
```

#### 2. Helper Module Pattern
**Location**: `app/helpers/solidstats/`

Each feature has a dedicated helper module for view logic:

```ruby
module Solidstats
  module FeatureNameHelper
    def feature_name_status_class(data)
      "status-#{data[:status] || 'ok'}"
    end

    def feature_name_status_icon(data)
      # Standardized status icons
    end

    def feature_name_value_display(data)
      # Formatted value presentation
    end

    def feature_name_trend_indicator(data)
      # Trend visualization helpers
    end
  end
end
```

#### 3. View Structure Standards
**Dashboard Summary**: `app/views/solidstats/dashboard/_feature_name_summary.html.erb`
**Detail View**: `app/views/solidstats/feature_name/index.html.erb`
**Controller**: `app/controllers/solidstats/feature_name_controller.rb`

#### 4. Testing Standards
**Service Tests**: `test/services/solidstats/feature_name_service_test.rb`
**Helper Tests**: `test/helpers/solidstats/feature_name_helper_test.rb`
**Controller Tests**: `test/controllers/solidstats/feature_name_controller_test.rb`

All tests must achieve **100% coverage** of public methods.

## Current Architecture Analysis

### View Structure
```
app/views/
├── layouts/solidstats/application.html.erb          # Basic layout
├── solidstats/dashboard/index.html.erb              # Main dashboard (1368 lines)
├── solidstats/dashboard/_todos.html.erb             # TODO items partial
├── solidstats/dashboard/_log_monitor.html.erb       # Log monitoring partial
├── solidstats/dashboard/audit/                      # Security audit partials
│   ├── _security_audit.html.erb
│   ├── _audit_details.html.erb
│   ├── _audit_summary.html.erb
│   ├── _vulnerabilities_table.html.erb
│   └── ... (additional audit partials)
└── solidstats/gem_metadata/
    ├── index.html.erb                               # Full gem metadata page (2022 lines)
    └── _panel.html.erb                              # Dashboard panel summary
```

### Key Issues Identified

1. **Monolithic Views**: Main dashboard file is 1368 lines with embedded CSS and JavaScript
2. **Inconsistent Component Structure**: Mix of partials and embedded content
3. **Duplicate Styles**: Similar UI patterns repeated across files
4. **Limited Reusability**: Components tightly coupled to specific contexts
5. **No View Component Architecture**: Missing modern Rails view component patterns

## Design System Foundation

### Color Strategy
Building on the existing Tailwind-compatible color scheme:

```scss
// Primary Colors
$primary-blue: #0366d6;
$primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);

// Status Colors
$status-ok: #28a745;
$status-warning: #ffc107;
$status-danger: #dc3545;
$status-info: #17a2b8;

// Neutral Colors
$gray-50: #f9fafb;
$gray-100: #f3f4f6;
$gray-200: #e5e7eb;
$gray-300: #d1d5db;
$gray-500: #6b7280;
$gray-600: #4b5563;
$gray-900: #111827;

// Severity Colors
$critical: #dc3545;
$high: #fd7e14;
$medium: #f39c12;
$low: #27ae60;
```

### Typography Scale
```scss
$font-family-base: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
$font-family-mono: SFMono-Regular, Menlo, Monaco, Consolas, monospace;

// Typography Scale
$text-xs: 0.75rem;
$text-sm: 0.875rem;
$text-base: 1rem;
$text-lg: 1.125rem;
$text-xl: 1.25rem;
$text-2xl: 1.5rem;
$text-3xl: 1.875rem;
```

### Spacing System
```scss
// Spacing Scale (Tailwind-compatible)
$space-1: 0.25rem;
$space-2: 0.5rem;
$space-3: 0.75rem;
$space-4: 1rem;
$space-6: 1.5rem;
$space-8: 2rem;
$space-12: 3rem;
$space-16: 4rem;
```

## Component Architecture

### 1. Core Layout Components

#### ApplicationLayout
**File**: `app/views/layouts/solidstats/application.html.erb`
**Purpose**: Main application wrapper with navigation and shared assets
**Status**: ✅ Keep as-is, minimal changes needed

#### DashboardNavigation
**New File**: `app/components/solidstats/dashboard_navigation_component.rb`
**Purpose**: Persistent navigation with section switching
**Features**:
- Responsive navigation bar
- Active state management
- Hash-based routing support
- Quick navigation menu

#### FloatingQuickNav
**New File**: `app/components/solidstats/floating_quick_nav_component.rb`
**Purpose**: Floating navigation for long pages
**Features**:
- Collapsible menu
- Smooth scrolling
- Section indicators

### 2. Dashboard Overview Components

#### StatsOverview
**New File**: `app/components/solidstats/stats_overview_component.rb`
**Purpose**: Main dashboard metrics cards
**Features**:
- Clickable cards for navigation
- Status-based styling
- Real-time updates

#### SummaryCard
**New File**: `app/components/solidstats/summary_card_component.rb`
**Purpose**: Reusable metric card component
**Props**:
```ruby
icon: String           # Emoji or icon class
title: String         # Card title
value: String|Integer # Main metric value
status: Symbol        # :ok, :warning, :danger
link_to: String       # Navigation target
```

### 3. Security Components

#### SecurityOverview
**New File**: `app/components/solidstats/security/overview_component.rb`
**Purpose**: Security dashboard section
**Features**:
- Security score visualization
- Risk level indicators
- Quick action buttons

#### SecurityScore
**New File**: `app/components/solidstats/security/score_component.rb`
**Purpose**: Circular security score display
**Features**:
- Grade-based scoring (A+ to F)
- Color-coded severity
- Animated score display

#### VulnerabilityTable
**New File**: `app/components/solidstats/security/vulnerability_table_component.rb`
**Purpose**: Filterable vulnerability listing
**Features**:
- Severity filtering
- Search functionality
- Bulk actions
- Export capabilities

#### GemImpactAnalysis
**New File**: `app/components/solidstats/security/gem_impact_analysis_component.rb`
**Purpose**: Gem-specific vulnerability analysis
**Features**:
- Gem grouping
- Update recommendations
- Action buttons

### 4. Code Quality Components

#### CodeQualityTabs
**New File**: `app/components/solidstats/code_quality/tabs_component.rb`
**Purpose**: Code quality section with tabbed interface
**Features**:
- Test coverage visualization
- TODO/FIXME tracking
- Log monitoring
- Code health metrics

#### TestCoverageCard
**New File**: `app/components/solidstats/code_quality/test_coverage_component.rb`
**Purpose**: Test coverage visualization
**Features**:
- Progress bar display
- Status-based coloring
- Coverage breakdown

#### TodoManager
**New File**: `app/components/solidstats/code_quality/todo_manager_component.rb`
**Purpose**: TODO/FIXME/HACK item management
**Features**:
- Type-based filtering
- File hotspot analysis
- Expandable item details
- Accordion interface

#### LogMonitor
**New File**: `app/components/solidstats/code_quality/log_monitor_component.rb`
**Purpose**: Log file size monitoring and management
**Features**:
- Size visualization
- Status indicators
- Truncation actions
- File-specific metrics

### 5. Gem Metadata Components

#### GemMetadataPanel
**New File**: `app/components/solidstats/gem_metadata/panel_component.rb`
**Purpose**: Dashboard gem overview panel
**Features**:
- Stats summary
- Quick navigation to full view
- Status indicators

#### GemMetadataIndex
**New File**: `app/components/solidstats/gem_metadata/index_component.rb`
**Purpose**: Full gem metadata page
**Features**:
- Dual view (grid/table)
- Search and filtering
- Sort capabilities
- Export functionality

#### GemCard
**New File**: `app/components/solidstats/gem_metadata/gem_card_component.rb`
**Purpose**: Individual gem display card
**Features**:
- Version comparison
- Dependency listing
- Update indicators
- Release information

### 6. Shared UI Components

#### TabContainer
**New File**: `app/components/solidstats/ui/tab_container_component.rb`
**Purpose**: Reusable tabbed interface
**Features**:
- Hash-based navigation
- Active state management
- Responsive design

#### StatusBadge
**New File**: `app/components/solidstats/ui/status_badge_component.rb`
**Purpose**: Consistent status indicators
**Props**:
```ruby
status: Symbol    # :ok, :warning, :danger, :info
size: Symbol      # :sm, :md, :lg
text: String      # Badge text
```

#### ActionButton
**New File**: `app/components/solidstats/ui/action_button_component.rb`
**Purpose**: Consistent button styling
**Props**:
```ruby
variant: Symbol   # :primary, :secondary, :danger
size: Symbol      # :sm, :md, :lg
icon: String      # Icon class or emoji
```

#### DataTable
**New File**: `app/components/solidstats/ui/data_table_component.rb`
**Purpose**: Reusable data table with common features
**Features**:
- Sorting
- Filtering
- Pagination
- Export capabilities

## Detailed Refactoring Plan

### Phase 1: Component Foundation
**Timeline**: 1-2 weeks

1. **Create Base Component Structure**
   ```bash
   mkdir -p app/components/solidstats/{ui,security,code_quality,gem_metadata}
   ```

2. **Extract Shared UI Components**
   - Create `StatusBadge`, `ActionButton`, `TabContainer`
   - Extract common CSS into component stylesheets
   - Implement base component class with shared functionality

3. **Setup Component Preview System**
   ```ruby
   # config/application.rb
   config.view_component.preview_paths << Rails.root.join("app/components/solidstats/previews")
   ```

### Phase 2: Dashboard Restructuring
**Timeline**: 2-3 weeks

1. **Break Down Main Dashboard** (`dashboard/index.html.erb`)
   
   **Current Structure** (1368 lines):
   ```erb
   <!-- Header and Navigation (lines 1-30) -->
   <header class="dashboard-header">...</header>
   
   <!-- Overview Section (lines 31-70) -->
   <section id="overview">...</section>
   
   <!-- Security Section (lines 71-280) -->
   <section id="security">...</section>
   
   <!-- Code Quality Section (lines 281-350) -->
   <section id="code-quality">...</section>
   
   <!-- Tasks Section (lines 351-400) -->
   <section id="tasks">...</section>
   
   <!-- Styles (lines 401-1200) -->
   <style>...</style>
   
   <!-- JavaScript (lines 1201-1368) -->
   <script>...</script>
   ```

   **Refactored Structure**:
   ```erb
   <%= render Solidstats::DashboardNavigationComponent.new %>
   
   <div class="solidstats-dashboard">
     <%= render Solidstats::StatsOverviewComponent.new(
       audit_data: @audit_summary,
       todo_data: @todo_summary,
       coverage: @coverage,
       log_data: @log_data
     ) %>
     
     <%= render Solidstats::Security::OverviewComponent.new(
       audit_output: @audit_output
     ) %>
     
     <%= render Solidstats::CodeQuality::TabsComponent.new(
       coverage: @coverage,
       todo_items: @todo_items,
       log_data: @log_data
     ) %>
     
     <%= render Solidstats::GemMetadata::PanelComponent.new %>
   </div>
   
   <%= render Solidstats::FloatingQuickNavComponent.new %>
   ```

2. **Create Section Components**
   - Extract each dashboard section into dedicated components
   - Move section-specific CSS to component stylesheets
   - Implement component-specific JavaScript with Stimulus controllers

3. **Implement Tab Navigation System**
   ```ruby
   # app/components/solidstats/ui/tab_container_component.rb
   class Solidstats::Ui::TabContainerComponent < ViewComponent::Base
     def initialize(tabs:, active_tab: nil, section: nil)
       @tabs = tabs
       @active_tab = active_tab
       @section = section
     end
     
     private
     
     attr_reader :tabs, :active_tab, :section
   end
   ```

### Phase 3: Security Section Refactoring
**Timeline**: 2 weeks

1. **Security Overview Component**
   ```ruby
   # app/components/solidstats/security/overview_component.rb
   class Solidstats::Security::OverviewComponent < ViewComponent::Base
     def initialize(audit_output:)
       @audit_output = audit_output
       @results = audit_output.dig("results") || []
     end
     
     private
     
     def security_score
       return "A+" if vulnerabilities_count.zero?
       return "C" if high_severity_count > 0
       "B"
     end
     
     def vulnerabilities_count
       @results.size
     end
     
     def high_severity_count
       @results.count { |r| %w[high critical].include?(criticality(r)) }
     end
   end
   ```

2. **Vulnerability Management Components**
   - Extract vulnerability table with filtering
   - Create gem impact analysis component
   - Implement security timeline visualization
   - Add bulk action capabilities

### Phase 4: Code Quality Components
**Timeline**: 2 weeks

1. **TODO Manager Refactoring**
   
   **Current**: `_todos.html.erb` (152 lines with embedded styles)
   
   **Refactored**:
   ```ruby
   # app/components/solidstats/code_quality/todo_manager_component.rb
   class Solidstats::CodeQuality::TodoManagerComponent < ViewComponent::Base
     def initialize(todo_items:, todo_summary:)
       @todo_items = todo_items
       @todo_summary = todo_summary
     end
     
     private
     
     def grouped_items
       @todo_items.group_by { |item| item[:type] || "TODO" }
     end
     
     def hotspot_files
       @todo_summary[:hotspots] || []
     end
   end
   ```

2. **Log Monitor Enhancement**
   
   **Current**: `_log_monitor.html.erb` (760 lines)
   
   **Refactored**:
   ```ruby
   # app/components/solidstats/code_quality/log_monitor_component.rb
   class Solidstats::CodeQuality::LogMonitorComponent < ViewComponent::Base
     def initialize(log_data:)
       @log_data = log_data
     end
     
     private
     
     def status_class
       "status-#{@log_data[:status]}"
     end
     
     def fill_percentage
       [(@log_data[:total_size_mb] / 50.0) * 100, 100].min
     end
   end
   ```

### Phase 5: Gem Metadata Modernization
**Timeline**: 2 weeks

1. **Dual View Implementation**
   
   **Current**: `gem_metadata/index.html.erb` (2022 lines)
   
   **Refactored Structure**:
   ```erb
   <%= render Solidstats::GemMetadata::IndexComponent.new(
     gems: @gems,
     view_mode: params[:view] || "grid"
   ) %>
   ```

2. **Enhanced Filtering and Search**
   ```ruby
   # app/components/solidstats/gem_metadata/filter_bar_component.rb
   class Solidstats::GemMetadata::FilterBarComponent < ViewComponent::Base
     def initialize(gems:, current_filters: {})
       @gems = gems
       @current_filters = current_filters
     end
     
     private
     
     def filter_options
       {
         status: ["all", "outdated", "up-to-date", "unavailable"],
         sort: ["name-asc", "name-desc", "status-desc", "release-desc"]
       }
     end
   end
   ```

### Phase 6: Asset Organization
**Timeline**: 1 week

1. **CSS Architecture**
   ```scss
   // app/assets/stylesheets/solidstats/application.scss
   @import "foundation/variables";
   @import "foundation/mixins";
   @import "foundation/base";
   
   @import "components/ui/buttons";
   @import "components/ui/badges";
   @import "components/ui/tables";
   @import "components/ui/tabs";
   
   @import "components/dashboard/navigation";
   @import "components/dashboard/overview";
   
   @import "components/security/overview";
   @import "components/security/vulnerability-table";
   
   @import "components/code-quality/todo-manager";
   @import "components/code-quality/log-monitor";
   
   @import "components/gem-metadata/panel";
   @import "components/gem-metadata/gem-card";
   ```

2. **JavaScript Organization**
   ```javascript
   // app/assets/javascripts/solidstats/application.js
   //= require_tree ./controllers
   //= require_tree ./components
   
   // Stimulus Controllers:
   // - dashboard_navigation_controller.js
   // - tab_container_controller.js
   // - vulnerability_table_controller.js
   // - gem_metadata_filter_controller.js
   ```

## Responsive Design Strategy

### Breakpoint System
```scss
$breakpoints: (
  sm: 640px,
  md: 768px,
  lg: 1024px,
  xl: 1280px,
  2xl: 1536px
);
```

### Mobile-First Responsive Patterns

1. **Dashboard Navigation**
   - Hamburger menu for mobile
   - Collapsible sections
   - Priority-based content hiding

2. **Stats Overview**
   - Single column on mobile
   - 2-column on tablet
   - 4-column on desktop

3. **Data Tables**
   - Card view on mobile
   - Horizontal scroll on tablet
   - Full table on desktop

4. **Security Overview**
   - Stacked metrics on mobile
   - Side-by-side on desktop

## Performance Considerations

### Component Loading Strategy
1. **Lazy Loading**: Load complex components on demand
2. **Progressive Enhancement**: Basic functionality without JavaScript
3. **Caching**: Component-level caching for expensive operations
4. **Asset Optimization**: Critical CSS inlining, JavaScript bundling

### Data Loading Optimization
1. **Service Layer**: Maintain existing service architecture
2. **Caching Strategy**: Cache audit results, gem metadata
3. **Background Processing**: Move expensive operations to background jobs
4. **Real-time Updates**: WebSocket integration for live data

## Testing Strategy

### Component Testing
```ruby
# test/components/solidstats/security/overview_component_test.rb
class Solidstats::Security::OverviewComponentTest < ViewComponent::TestCase
  def test_renders_security_score_correctly
    audit_data = { "results" => [] }
    component = Solidstats::Security::OverviewComponent.new(audit_output: audit_data)
    
    render_inline(component)
    
    assert_selector ".security-score", text: "A+"
    assert_selector ".score-excellent"
  end
end
```

### Integration Testing
```ruby
# test/system/dashboard_test.rb
class DashboardTest < ApplicationSystemTestCase
  def test_dashboard_navigation
    visit solidstats.root_path
    
    click_on "Security"
    assert_current_path "#security"
    assert_selector ".security-overview"
    
    click_on "Code Quality"
    assert_current_path "#code-quality"
    assert_selector ".code-quality-tabs"
  end
end
```

## Migration Timeline

### Week 1-2: Foundation
- [ ] Setup ViewComponent gem
- [ ] Create base component structure
- [ ] Extract shared UI components
- [ ] Setup component preview system

### Week 3-4: Dashboard Core
- [ ] Refactor main dashboard layout
- [ ] Extract navigation component
- [ ] Create stats overview component
- [ ] Implement tab navigation system

### Week 5-6: Security Section
- [ ] Extract security overview component
- [ ] Refactor vulnerability table
- [ ] Create gem impact analysis
- [ ] Implement security timeline

### Week 7-8: Code Quality
- [ ] Refactor TODO manager
- [ ] Extract log monitor component
- [ ] Create test coverage component
- [ ] Implement code health metrics

### Week 9-10: Gem Metadata
- [ ] Refactor gem metadata index
- [ ] Implement dual view system
- [ ] Create filtering components
- [ ] Add export functionality

### Week 11: Polish & Testing
- [ ] Asset organization
- [ ] Performance optimization
- [ ] Comprehensive testing
- [ ] Documentation updates

## Implementation Guidelines

### Component Creation Checklist
- [ ] Create component class with proper initialization
- [ ] Create corresponding template file
- [ ] Add component-specific stylesheet
- [ ] Create Stimulus controller if needed
- [ ] Write component tests
- [ ] Create component preview
- [ ] Update documentation

### Code Quality Standards
- [ ] Follow Rails and ViewComponent conventions
- [ ] Maintain consistent naming patterns
- [ ] Use semantic HTML markup
- [ ] Implement accessibility features
- [ ] Optimize for performance
- [ ] Include comprehensive error handling

### Review Process
1. **Component Review**: Each component should be reviewed for reusability and adherence to design system
2. **Integration Review**: Ensure components work together seamlessly
3. **Performance Review**: Check for loading times and memory usage
4. **Accessibility Review**: Verify WCAG compliance
5. **Mobile Review**: Test on various device sizes

## Future Enhancements

### Phase 2 Features (Post-Refactoring)
1. **Real-time Updates**: WebSocket integration for live dashboard updates
2. **Custom Dashboards**: User-configurable dashboard layouts
3. **Alerts & Notifications**: Configurable alerts for security issues
4. **Historical Data**: Trend analysis and historical comparisons
5. **Export & Reporting**: PDF/CSV export capabilities
6. **API Integration**: REST API for external integrations

### Advanced UI Features
1. **Dark Mode**: Theme switching capability
2. **Advanced Filtering**: Date ranges, custom filters
3. **Drag & Drop**: Customizable dashboard layout
4. **Keyboard Navigation**: Full keyboard accessibility
5. **Progressive Web App**: Offline capabilities

## Conclusion

This design blueprint provides a comprehensive roadmap for modernizing the Solidstats UI/UX while maintaining its core functionality. The component-based architecture will improve maintainability, reusability, and consistency across the application.

The phased approach ensures minimal disruption to existing functionality while systematically improving the codebase. Each phase builds upon the previous one, allowing for iterative improvements and early feedback.

By following this blueprint, the Solidstats dashboard will evolve into a modern, maintainable, and user-friendly developer tool that scales with growing requirements while maintaining its clean, professional appearance.

## UI/UX Design Standards

### Dashboard Integration Points

#### Summary Cards
All features appear as summary cards in the main dashboard:

```erb
<div class="summary-card <%= feature_status_class(data) %>" 
     data-section="<%= section %>" 
     data-tab="<%= feature_name.dasherize %>">
  <div class="summary-icon"><%= feature_icon %></div>
  <div class="summary-data">
    <div class="summary-value"><%= data[:value] %></div>
    <div class="summary-label"><%= feature_human_name %></div>
  </div>
</div>
```

#### Section Organization
Features are organized into logical sections:
- **overview**: High-level system health
- **security**: Security-related metrics  
- **code-quality**: Code health and standards
- **metrics**: Performance and usage data
- **dependencies**: Gem and library management

### Visual Design System

#### Status Color System
```scss
// Status indicators (consistent across all features)
.status-good    { --status-color: #28a745; }  // Green
.status-warning { --status-color: #ffc107; }  // Yellow
.status-critical{ --status-color: #dc3545; }  // Red
.status-info    { --status-color: #17a2b8; }  // Blue
.status-ok      { --status-color: #28a745; }  // Green (alias)
```

#### Component Structure Standards
```scss
// Standard component layout
.summary-card {
  display: flex;
  align-items: center;
  padding: 1.5rem;
  background: linear-gradient(135deg, var(--status-color, #667eea) 0%, #764ba2 100%);
  color: white;
  border-radius: 12px;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.summary-icon {
  font-size: 2rem;
  margin-right: 1rem;
}

.summary-data {
  flex: 1;
}

.summary-value {
  font-size: 1.875rem;
  font-weight: bold;
  line-height: 1.2;
}

.summary-label {
  font-size: 0.875rem;
  opacity: 0.9;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
```

#### Responsive Design Requirements
- **Mobile-first approach**: All components must work on 320px+ screens
- **Breakpoints**: 
  - `sm`: 640px (mobile)
  - `md`: 768px (tablet)
  - `lg`: 1024px (desktop)
  - `xl`: 1280px (large desktop)

## Feature Generator Usage Patterns

### Creating New Features

#### Basic Feature Creation
```bash
rails generate solidstats:feature database_performance
```

This creates:
- Service with caching: `DatabasePerformanceService`
- Helper module: `DatabasePerformanceHelper`
- Dashboard summary partial: `_database_performance_summary.html.erb`
- Detail view: `database_performance/index.html.erb`
- Controller: `DatabasePerformanceController`
- Complete test suite
- Route integration
- Dashboard integration

#### Advanced Feature Creation
```bash
rails generate solidstats:feature memory_usage \
  --icon=🧠 \
  --section=performance \
  --cache-hours=2 \
  --status-colors=true
```

### Mandatory Implementation Steps

After generating a feature, developers **MUST**:

1. **Implement Service Logic**
   ```ruby
   # app/services/solidstats/feature_name_service.rb
   private
   
   def collect_data
     # TODO: Implement actual data collection
     {
       value: calculate_primary_metric,
       status: determine_health_status,
       last_updated: Time.current,
       details: gather_detailed_metrics
     }
   end
   
   def calculate_summary_value(data)
     # TODO: Format for dashboard display
   end
   
   def determine_status(data)
     # TODO: Return :good, :warning, :critical, or :info
   end
   ```

2. **Customize Helper Methods**
   ```ruby
   # app/helpers/solidstats/feature_name_helper.rb
   def feature_name_value_display(data)
     # TODO: Format values for display
   end
   
   def feature_name_trend_indicator(data)
     # TODO: Show trend arrows or indicators
   end
   ```

3. **Complete Template Content**
   ```erb
   <%# app/views/solidstats/dashboard/_feature_name_summary.html.erb %>
   <div class="feature-summary <%= feature_name_status_class(@feature_name_data) %>">
     <!-- TODO: Implement summary card content -->
   </div>
   ```

4. **Implement Controller Actions**
   ```ruby
   # app/controllers/solidstats/feature_name_controller.rb
   def index
     @feature_data = FeatureNameService.new.fetch
     # TODO: Add any view-specific data processing
   end
   ```

5. **Write Comprehensive Tests**
   - Service unit tests with edge cases
   - Helper method tests
   - Controller integration tests
   - System tests for UI interactions

### Code Style Guidelines

#### Naming Conventions
- **Services**: `FeatureNameService` (e.g., `MemoryUsageService`)
- **Helpers**: `FeatureNameHelper` (e.g., `MemoryUsageHelper`)
- **Controllers**: `FeatureNameController` (e.g., `MemoryUsageController`)
- **Cache Keys**: `"solidstats_feature_name"` (e.g., `"solidstats_memory_usage"`)

#### Service Method Standards
```ruby
# Required public methods
def fetch(force_refresh = false)  # Main data retrieval
def summary                       # Dashboard card data
def detailed_view                 # Full page data (optional)

# Required private methods  
def collect_data                  # Core data collection
def calculate_summary_value(data) # Dashboard value formatting
def determine_status(data)        # Status determination
def cache_data(data)             # Caching implementation
def cached_data                  # Cache retrieval
def cache_expired?               # Cache validation
```

#### Helper Method Standards
```ruby
# Required helper methods
def feature_name_status_class(data)    # CSS class for status
def feature_name_status_icon(data)     # Icon for status
def feature_name_status_text(data)     # Human-readable status
def feature_name_value_display(data)   # Formatted value

# Optional helper methods
def feature_name_trend_indicator(data)  # Trend visualization
def feature_name_action_buttons(data)   # Action controls
def feature_name_details_link(data)     # Link to detail view
```

## Quality Assurance Standards

### Testing Requirements

#### Service Tests
```ruby
class FeatureNameServiceTest < ActiveSupport::TestCase
  # Required tests
  test "fetch returns cached data when cache is fresh"
  test "fetch collects new data when cache is expired"
  test "fetch forces refresh when requested"
  test "summary returns properly formatted data"
  test "handles errors gracefully"
  
  # Status-specific tests
  test "determines good status for healthy metrics"
  test "determines warning status for concerning metrics"
  test "determines critical status for dangerous metrics"
end
```

#### Helper Tests
```ruby
class FeatureNameHelperTest < ActionView::TestCase
  # Required tests
  test "status_class returns correct CSS class"
  test "status_icon returns appropriate icon"
  test "value_display formats numbers correctly"
  test "handles nil and empty data gracefully"
end
```

#### Integration Tests
```ruby
class FeatureNameControllerTest < ActionDispatch::IntegrationTest
  test "index displays feature data"
  test "handles service errors gracefully"
  test "responds to JSON requests"
end
```

### Performance Standards

#### Caching Requirements
- **Default cache duration**: 1 hour (configurable via generator option)
- **Cache key format**: `"solidstats_#{feature_name}"`
- **Cache storage**: File-based in `tmp/` directory
- **Cache invalidation**: Time-based with force refresh option

#### Service Performance
- **Response time**: < 100ms for cached data
- **Data collection**: < 5 seconds for fresh data
- **Memory usage**: < 10MB per service instance
- **Error handling**: Graceful degradation with fallback values

## Development Workflow

### Pre-Development Checklist
- [ ] Review existing features for similar patterns
- [ ] Identify data sources and collection methods
- [ ] Plan caching strategy based on data volatility
- [ ] Design status determination logic
- [ ] Sketch dashboard integration approach

### Development Process
1. **Generate Feature**: Use the feature generator with appropriate options
2. **Implement Service**: Complete the data collection and processing logic
3. **Customize Helpers**: Add feature-specific formatting and display logic
4. **Style Components**: Create feature-specific SCSS if needed
5. **Write Tests**: Achieve 100% coverage of all public methods
6. **Integration Testing**: Test dashboard integration and navigation
7. **Documentation**: Update feature documentation and examples

### Post-Development Checklist
- [ ] Service implements all required methods
- [ ] Helper methods handle edge cases
- [ ] Tests achieve 100% coverage
- [ ] Feature integrates properly with dashboard
- [ ] Performance meets established benchmarks
- [ ] Documentation is complete and accurate
- [ ] Code follows style guidelines

### Code Review Guidelines

#### Service Review Points
- [ ] Efficient data collection implementation
- [ ] Proper error handling and fallbacks
- [ ] Appropriate caching strategy
- [ ] Clear status determination logic
- [ ] Consistent return value formats

#### Helper Review Points
- [ ] Safe handling of nil/empty data
- [ ] Consistent formatting patterns
- [ ] Accessible HTML output
- [ ] Reusable method design

#### Template Review Points
- [ ] Semantic HTML structure
- [ ] Responsive design implementation
- [ ] Accessibility features included
- [ ] Consistent with design system

### Maintenance Standards

#### Regular Maintenance Tasks
- **Weekly**: Review service performance metrics
- **Monthly**: Update cache durations based on usage patterns
- **Quarterly**: Refactor common patterns into shared utilities
- **Annually**: Review and update design system standards

#### Monitoring Requirements
- Track service response times
- Monitor cache hit/miss ratios
- Watch for error rates and patterns
- Measure user engagement with features

#### Documentation Maintenance
- Keep generator documentation current
- Update examples with real implementations
- Maintain troubleshooting guides
- Document performance optimization tips

## Future Development Considerations

### Scalability Planning
- Design services for horizontal scaling
- Plan for increased data volumes
- Consider background job integration
- Prepare for real-time update requirements

### Technology Evolution
- Stay current with Rails best practices
- Monitor ViewComponent ecosystem developments
- Plan for potential architecture migrations
- Evaluate new testing approaches

### User Experience Evolution
- Gather user feedback on feature utility
- Plan for customizable dashboard layouts
- Consider mobile application needs
- Evaluate accessibility improvements

This design guide establishes a solid foundation for consistent, maintainable, and scalable feature development in the Solidstats ecosystem. All future development should adhere to these standards to ensure quality and consistency across the codebase.
