require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

# These gems aren't always present
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError
end

test_tasks = [
  :metadata,
  :clean_fixtures,
  :syntax,
  :lint,
  :validate,
  :spec
]

PuppetLint.configuration.relative = true
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.fail_on_warnings = true

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  ".vendor/**/*",
  "spec/**/*",
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

desc "Run acceptance tests"
RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/acceptance'
end

begin
  require 'inch/rake'
  Inch::Rake::Suggest.new :inch, '--pedantic'
  test_tasks << :inch
rescue LoadError
  # do nothing
end

desc "Validate manifests, templates, and ruby files"
task :validate do
  Dir['manifests/**/*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
  Dir['templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end

desc "Clean fixtures"
task :clean_fixtures do
  FileUtils.rmtree 'spec/fixtures/modules'
end

desc "Run syntax, lint, and spec tests."
task :test => test_tasks

