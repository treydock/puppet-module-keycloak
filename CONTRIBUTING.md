# PDK setup

PDK needs the bundler gem for each Ruby version tested in this module. For
example:

    $ sudo /opt/puppetlabs/pdk/private/ruby/2.4.9/bin/gem install bundler
    $ sudo /opt/puppetlabs/pdk/private/ruby/2.5.7/bin/gem install bundler

After bundler is installed you can run normal PDK commands such as

    $ pdk validate
    $ pdk test unit

# Release Process

1. Update metadata.json version, eg: `pdk bundle exec rake module:bump:{major,minor,patch}`
1. Run release task, eg: `pdk bundle exec rake release`
1. Update GitHub pages, eg: `pdk bundle exec rake strings:gh_pages:update`
1. Push to GitHub: `git push --tags origin master`
