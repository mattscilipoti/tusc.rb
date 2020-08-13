source "https://rubygems.org"

ruby '2.7.1'

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in tusc_rb.gemspec
gemspec

gem 'amazing_print', '~> 1.2', :group => [:development, :test]
gem 'bundler', '~> 1.17', :group => [:development, :test, :ci]
gem 'pry-byebug', '~> 3.9', :group => [:development, :test]
gem 'rake', '~> 13.0', :group => [:development, :test, :ci]
gem 'rspec', '~> 3.0', :group => [:development, :test, :ci]
gem 'tus-server', '~> 2.3', require: false, :group => [:development]
gem 'webmock', '~> 3.8', require: false, :group => [:development]
gem 'yard', '~> 0.9', require: false, :group => [:development]
