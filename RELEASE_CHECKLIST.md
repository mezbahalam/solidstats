# Release Checklist for SolidStats v1.1.0

## Pre-release Tasks
- [x] Update version number in `lib/solidstats/version.rb` to "1.1.0"
- [x] Update CHANGELOG.md with release notes for v1.1.0
- [x] Update README.md with latest features and usage instructions
- [x] Update gemspec with improved description
- [x] Update release rake task (if needed)

## Build and Test
- [ ] Run `bundle install` to ensure dependencies are up to date
- [ ] Run test suite to ensure everything passes
- [ ] Build gem locally with `rake solidstats:release`
- [ ] Install the gem locally to verify it works

## Release
- [ ] Create a release branch: `git checkout -b release/v1.1.0`
- [ ] Commit all changes: `git add . && git commit -m "Prepare release v1.1.0"`
- [ ] Push the branch: `git push origin release/v1.1.0`
- [ ] Create a pull request from `release/v1.1.0` to `main`
- [ ] After PR is reviewed and merged:
  - [ ] Push the gem to RubyGems.org with `gem push solidstats-1.1.0.gem`
  - [ ] Verify the gem is available on RubyGems.org
  - [ ] Tag the release in Git: `git checkout main && git pull && git tag -a v1.1.0 -m "Version 1.1.0 release"`
  - [ ] Push the tag: `git push origin v1.1.0`

## Post-release
- [ ] Update demo site (if applicable)
- [ ] Announce release on appropriate channels
- [ ] Start planning for next release

## Notes
- Remember to update the `rails g solidstats:install` generator if there are new features that require configuration
- Ensure the gem is compatible with all supported Ruby/Rails versions
