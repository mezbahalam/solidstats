
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

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
