source "http://rubygems.org"
gemspec
gem 'health-data-standards', :git => 'https://github.com/projectcypress/health-data-standards.git', :branch => 'master'
#gem 'health-data-standards', :path => '../health-data-standards'

gem 'rake'
gem 'pry'
gem 'tilt'
gem 'rails', '3.2.14'

# needed for parsing value sets (we need to use roo rather than rubyxl because the value sets are in xls rather than xlsx)
gem 'roo'

group :test do
  gem 'simplecov', :require => false

  gem 'minitest', "~> 4.0"
  gem 'turn', :require => false
  gem 'awesome_print', :require => 'ap'
end

