# Solidstats Feature Generator

## Overview

The Solidstats Feature Generator creates comprehensive boilerplate code for new dashboard features. It follows a consistent pattern and generates all necessary files including services, components, views, controllers, and tests.

## Usage

```bash
rails generate solidstats:feature FEATURE_NAME [options]
```

### Basic Example

```bash
rails generate solidstats:feature memory_usage
```

This creates a complete memory usage monitoring feature with:
- Data collection service with caching
- Dashboard summary component
- Detail view with filtering/sorting
- Controller with JSON API support
- Comprehensive test suite

### Advanced Example

```bash
rails generate solidstats:feature cpu_metrics \
  --icon=🖥️ \
  --section=performance \
  --cache-hours=2
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `--icon` | string | 📊 | Icon displayed in dashboard |
| `--section` | string | metrics | Dashboard section (overview, security, code-quality, metrics) |
| `--status-colors` | boolean | true | Include status-based coloring |
| `--cache-hours` | numeric | 1 | Cache duration in hours |

## Generated Files

The generator creates the following file structure:

```
app/
├── services/solidstats/
│   └── {feature_name}_service.rb          # Data collection with caching
├── helpers/solidstats/
│   └── {feature_name}_helper.rb           # Component helper methods
├── views/solidstats/
│   ├── dashboard/
│   │   └── _{feature_name}_summary.html.erb  # Dashboard summary card
│   └── {feature_name}/
│       ├── index.html.erb                 # Full detail view
│       └── preview.html.erb               # Component preview
├── controllers/solidstats/
│   └── {feature_name}_controller.rb       # Development-only controller
└── assets/stylesheets/solidstats/
    └── {feature_name}_component.scss      # Component styling

test/
├── services/solidstats/
│   └── {feature_name}_service_test.rb     # Service tests
├── helpers/solidstats/
│   └── {feature_name}_helper_test.rb      # Helper tests
└── controllers/solidstats/
    └── {feature_name}_controller_test.rb  # Controller tests
```

## Architecture

### Service Layer
- **Data Collection**: Implements `collect_data` method for gathering metrics
- **Caching**: Automatic file-based caching with configurable duration
- **Error Handling**: Graceful degradation with fallback data
- **Status Detection**: Smart status determination based on data patterns

### Component System
- **Helper Class**: Provides data formatting and status logic
- **Partial Template**: Reusable HTML with responsive design
- **Status Indicators**: Color-coded status with icons
- **Responsive Layout**: Mobile-first design with grid layouts

### Views
- **Summary Cards**: Dashboard integration with click-to-expand
- **Detail Views**: Full-page views with filtering and sorting
- **Empty States**: User-friendly messages when no data available
- **Error States**: Graceful error handling and retry options

### Testing
- **Service Tests**: Data collection, caching, and error scenarios
- **Component Tests**: Helper methods and template rendering
- **Controller Tests**: Access control and JSON API responses

## Dashboard Integration

The generator automatically integrates the new feature with the existing dashboard:

1. **Summary Card**: Added to the dashboard overview
2. **Navigation**: Feature added to dashboard navigation
3. **Controller Integration**: Data loading in dashboard controller
4. **Routes**: Automatic route configuration

## Example Service Implementation

After generation, implement the data collection logic:

```ruby
# app/services/solidstats/memory_usage_service.rb
private

def collect_data
  {
    value: current_memory_usage,
    items: detailed_memory_breakdown,
    status: determine_memory_status,
    metadata: {
      total_memory: total_system_memory,
      last_updated: Time.current
    }
  }
end

def current_memory_usage
  # Implement memory collection logic
  `ps -o pid,ppid,%mem,rss,command -ax`.lines[1..-1].sum { |line| line.split[3].to_i }
end

def determine_memory_status
  usage_percent = (current_memory_usage.to_f / total_system_memory * 100)
  
  case usage_percent
  when 0..70 then :good
  when 71..85 then :warning  
  else :critical
  end
end
```

## Status System

The generator includes a flexible status system:

- **good** (green): Normal operation
- **warning** (yellow): Attention needed
- **critical** (red): Immediate action required
- **info** (blue): Informational status
- **unknown** (gray): Status cannot be determined

## Customization

### Adding Custom Statuses

Modify the helper class to add custom status logic:

```ruby
def status_class
  case data[:status]&.to_sym
  when :excellent then 'status-excellent'
  when :maintenance then 'status-maintenance'
  else super
  end
end
```

### Custom Styling

Extend the generated SCSS with custom styles:

```scss
// app/assets/stylesheets/solidstats/{feature_name}_component.scss

.{feature-name}-component {
  .custom-metric {
    display: flex;
    align-items: center;
    
    .metric-icon {
      margin-right: 8px;
    }
  }
}
```

## Best Practices

1. **Data Collection**: Keep data collection methods fast and lightweight
2. **Caching**: Use appropriate cache durations based on data volatility
3. **Error Handling**: Always provide fallback data for graceful degradation
4. **Testing**: Write comprehensive tests for all scenarios
5. **Performance**: Consider the impact of data collection on application performance

## Troubleshooting

### Common Issues

**Generator not found**
```bash
# Ensure the gem is properly installed
bundle install

# Check if generator is available
rails generate --help | grep solidstats
```

**Template errors**
- Check that all required variables are available in templates
- Ensure ERB syntax is correct
- Verify file permissions

**Integration issues**
- Ensure dashboard files exist before running generator
- Check that routes file has the correct structure
- Verify controller integration points exist

## Contributing

When creating new features with this generator:

1. Run the generator with appropriate options
2. Implement the data collection logic
3. Customize the component template as needed
4. Add comprehensive tests
5. Update documentation if needed

## Examples

### System Monitoring Features
```bash
rails g solidstats:feature disk_usage --icon=💾 --section=system
rails g solidstats:feature cpu_load --icon=⚡ --section=performance  
rails g solidstats:feature network_stats --icon=🌐 --section=system
```

### Security Features
```bash
rails g solidstats:feature vulnerability_scan --icon=🔒 --section=security
rails g solidstats:feature access_logs --icon=🔑 --section=security
```

### Code Quality Features
```bash
rails g solidstats:feature test_coverage --icon=✅ --section=code-quality
rails g solidstats:feature code_complexity --icon=📊 --section=code-quality
```
