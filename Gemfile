source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :test do
  gem 'rake',                        :require => false
  gem 'puppetlabs_spec_helper',      :require => false
  gem 'rspec-puppet',                :require => false
  gem 'metadata-json-lint',          :require => false
  gem 'json',                        :require => false
  if RUBY_VERSION < '1.9.0'
    gem 'rspec-its',                 :require => false
    gem 'rspec', '~> 3.1.0',         :require => false
  end

  if RUBY_VERSION >= '1.9.0'
    gem 'inch',                      :require => false
    gem 'beaker',                    :require => false
    gem 'beaker-rspec',              :require => false
    gem 'coveralls',                 :require => false
    gem 'codeclimate-test-reporter', :require => false
    gem 'simplecov',                 :require => false
  end
end

if facterver = ENV['FACTER_VERSION']
  gem 'facter', facterver,           :require => false
else
  gem 'facter',                      :require => false
end
puppetver = if RUBY_VERSION < '1.9.0' then '~> 2.7.0' else ENV['PUPPET_VERSION'] end
if puppetver
  gem 'puppet', puppetver,           :require => false
  if Gem::Requirement.new(puppetver) =~ Gem::Version.new('2.7.0')
    gem 'hiera-puppet',              :require => false
  end
else
  gem 'puppet', '~> 3.0',            :require => false
end

group :development do
  gem 'vagrant-wrapper',             :require => false
  if RUBY_VERSION >= '1.9.0'
    gem 'puppet-blacksmith',         :require => false
    gem 'guard-rake',                :require => false
    if RUBY_VERSION >= '2.0.0'
      gem 'pry-byebug',              :require => false
    else
      gem 'pry-debugger',            :require => false
    end
  end
  gem 'pry', '~> 0.9.0',             :require => false if RUBY_VERSION < '1.9.0'
end
# vim:ft=ruby
