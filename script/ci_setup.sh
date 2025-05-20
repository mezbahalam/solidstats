#!/bin/bash
# ci_setup.sh - Script to prepare the environment for CI testing

# Ensure bundler is installed
gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1 | tr -d ' ')" --no-document

# Clear any existing bundle configuration
bundle config --delete frozen
bundle config --delete path
bundle config --delete deployment

# Explicitly set bundler to not be frozen
bundle config set --local frozen false
bundle config set --local path vendor/bundle

# Show the current bundle config
echo "Current bundle configuration:"
bundle config list

echo "CI setup completed successfully!"
