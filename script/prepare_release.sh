#!/usr/bin/env zsh
# This script helps with the SolidStats release process

set -e # Exit on error

# Get the current version
VERSION=$(ruby -r ./lib/solidstats/version.rb -e "puts Solidstats::VERSION")
echo "Preparing release for SolidStats v$VERSION..."

# Check if we're on the correct branch
BRANCH=$(git branch --show-current)
if [[ $BRANCH != "release/v$VERSION" ]]; then
  echo "Creating release branch: release/v$VERSION"
  git checkout -b release/v$VERSION
else
  echo "Already on release branch: $BRANCH"
fi

# Clean up any old gem builds
echo "Cleaning up old gem builds..."
rm -f solidstats-*.gem

# Build the gem
echo "Building the gem..."
gem build solidstats.gemspec

# Verify build
if [[ -f "solidstats-$VERSION.gem" ]]; then
  echo "Successfully built solidstats-$VERSION.gem"
else
  echo "Error: Failed to build gem"
  exit 1
fi

# Check if there are uncommitted changes
if [[ $(git status --porcelain | wc -l) -ne 0 ]]; then
  echo "Committing changes..."
  git add .
  git commit -m "Prepare release v$VERSION"
else
  echo "No changes to commit"
fi

# Instructions for next steps
echo ""
echo "Release preparation complete!"
echo ""
echo "Next steps:"
echo "1. Push the branch:"
echo "   git push origin release/v$VERSION"
echo ""
echo "2. Create a pull request from release/v$VERSION to main"
echo "   Use the template in PULL_REQUEST_TEMPLATE.md"
echo ""
echo "3. After the PR is merged:"
echo "   gem push solidstats-$VERSION.gem"
echo "   git checkout main && git pull"
echo "   git tag -a v$VERSION -m \"Version $VERSION release\""
echo "   git push origin v$VERSION"
