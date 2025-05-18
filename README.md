
Solidstats is a local-only Rails engine that shows your project's health at `/solidstats`.

## Features
- Bundler Audit scan
- Rubocop offense count
- TODO/FIXME tracker
- Test coverage summary

## Installation

```ruby
# Gemfile (dev only)
group :development do
  gem 'solidstats', path: '../solidstats'
end
```

Then mount in `config/routes.rb`:

```ruby
mount Solidstats::Engine => '/solidstats' if Rails.env.development?
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
