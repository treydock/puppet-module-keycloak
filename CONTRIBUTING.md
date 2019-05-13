# Release Process

1. Update metadata.json version, eg: `pdk bundle exec rake module:bump:{major,minor,patch}`
1. Generate REFERENCE.md: `pdk bundle exec rake strings:generate:reference`
1. Update CHANGELOG.md: `pdk bundle exec rake changelog`
1. Commit changes, eg `git commit -a -m "Release $(cat metadata.json | jq -r '.version')"`
1. Tag, eg: `pdk bundle exec rake module:tag`
1. Update GitHub pages: `pdk bundle exec rake strings:gh_pages:update`
1. Push to GitHub: `git push --tags origin master`
