source 'http://rubygems.org'

gem 'rails', '3.1.1'
gem 'jquery-rails'
gem 'pg'
gem 'hirb'
gem "squeel" 
gem "ransack"
gem "simple_form"
gem "rabl"
gem "rmagick"
gem "carrierwave"
gem 'fog'
gem 'cancan'
gem "bcrypt-ruby", :require => "bcrypt"
gem 'debugger', group: [:development, :test]

group :assets do
  #gem 'sass-rails',   '~> 3.1.4'
  gem 'sass-rails',   :git => 'https://github.com/rails/sass-rails.git', :ref => 'fc56843'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'bootstrap-sass'
end

group :development do
  #gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'annotate', '~> 2.4.1.beta'
  #gem 'letter_opener', :git => 'https://github.com/bensmith283/letter_opener.git', :ref => '2024663'
  #gem 'letter_opener', :git => 'https://github.com/bensmith283/letter_opener.git', :branch => 'bugfix_windows_URI'
  #gem 'letter_opener'
end

group :production, :staging do
  gem 'thin'
end



