source 'https://rubygems.org'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.1.3'
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem 'propshaft'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '>= 2.1'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'
# local cerebras sdk
gem 'cerebras', '0.1.0', github: 'ton-anywhere/cerebras-cloud-sdk-ruby'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[ windows jruby ]

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'dotenv-rails'
  gem 'debug', platforms: %i[ mri windows ], require: 'debug/prelude'
  gem 'rubocop-rails-omakase', require: false
end

gem 'rspec-rails', '~> 8.0', groups: [ :development, :test ]

gem 'turbo-rails', '~> 2.0'

gem 'importmap-rails', '~> 2.2'

gem 'tailwindcss-rails', '~> 4.6'

gem 'stimulus-rails', '~> 1.3'
