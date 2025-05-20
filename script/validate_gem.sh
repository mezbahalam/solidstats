#!/bin/bash
# Script to validate gemspec and bundler compatibility

echo "=== Validating gemspec and bundle compatibility ==="
echo "Current Ruby version: $(ruby -v)"

# Check if the gemspec is valid
echo -e "\n=== Validating gemspec ==="
ruby -e "require 'rubygems'; require './solidstats.gemspec'"
if [ $? -eq 0 ]; then
  echo "✅ Gemspec is valid"
else
  echo "❌ Gemspec validation failed"
  exit 1
fi

# Test bundle install with different Ruby version constraints
echo -e "\n=== Testing bundler compatibility ==="
BUNDLE_FROZEN=false bundle install
if [ $? -eq 0 ]; then
  echo "✅ Bundle install successful"
else
  echo "❌ Bundle install failed"
  exit 1
fi

echo -e "\n=== All validation checks passed! ==="
