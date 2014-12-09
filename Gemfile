source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :test do
  gem "rake",                   :require => false
  gem "rspec-puppet",           :require => false, :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppetlabs_spec_helper", :require => false
  gem "metadata-json-lint",     :require => false
  gem "json",                   :require => false
  if RUBY_VERSION < "1.9.0"
    gem "rspec-its",              :require => false
  end

  if RUBY_VERSION >= "1.9.0"
    gem "beaker", "~> 1.20.0",  :require => false
    gem "beaker-rspec",         :require => false
    gem 'coveralls',            :require => false
    gem 'simplecov',            :require => false
  end
  if facterversion = ENV['FACTER_GEM_VERSION']
    gem 'facter', facterversion, :require => false
  else
    gem 'facter',               :require => false
  end
  if puppetversion = ENV['PUPPET_GEM_VERSION']
    gem 'puppet', puppetversion, :require => false
  else
    gem 'puppet',               :require => false
  end
end

group :development do
  gem "inch",                   :require => false
  gem "travis",                 :require => false
  gem "travis-lint",            :require => false
  gem "vagrant-wrapper",        :require => false
  if RUBY_VERSION >= "1.9.0"
    gem "puppet-blacksmith",    :require => false
    gem "guard-rake",           :require => false
    if RUBY_VERSION >= "2.0.0"
      gem 'pry-byebug',         :require => false
    else
      gem 'pry-debugger',       :require => false
    end
  end
end
# vim:ft=ruby
