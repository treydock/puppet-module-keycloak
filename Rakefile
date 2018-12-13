require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet-strings/tasks'

task :default do
  sh %{rake -T}
end

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]

Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
  config.ignore_paths = exclude_paths
  config.fail_on_warnings = true
  config.log_format = "%{path}:%{line}:%{check}:%{KIND}:%{message}"
  config.disable_checks = ['140chars', 'class_inherits_from_params_class']
  #config.relative = true
end
PuppetLint.configuration.relative = true

PuppetSyntax.exclude_paths = exclude_paths

desc "Run syntax, lint, and spec tests."
task :test => [
  :syntax,
  :lint,
  :spec,
]

desc "Run release prep commands"
task :release_prep, [:release] do |t, args|
  metadata_json = File.join(File.dirname(__FILE__), 'metadata.json')
  metadata = JSON.load(File.read(metadata_json))
  author = metadata['author']
  project = metadata['project_page'].split('/')[-1]
  if args[:release].nil?
    release = metadata['version']
  else
    release = args[:release]
  end


  sh "github_changelog_generator --user #{author} --project #{project} --output /dev/stdout --future-release #{release}"
  sh "puppet strings generate --format markdown"
end

desc "Run release commands"
task :release do
  Rake::Task[:build].invoke
  Rake::Task[:'strings:gh_pages:update'].invoke
end
