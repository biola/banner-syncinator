source 'https://rubygems.org'

gem 'actionpack', '~> 3.2.22' # apparently needed by exception_notification
gem 'blazing'
gem 'oj'
gem 'rails_config'
gem 'rake'
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'trogdir_api_client'
gem 'weary', github: 'biola/weary', branch: 'preserve_empty_params'

group :development, :staging, :production do
  gem 'ruby-oci8'
end

group :development, :test do
  gem 'pry'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'rspec'
end

group :test do
  gem 'webmock'
  gem 'factory_girl'
  gem 'faker'
  gem 'trogdir_api'
end

group :production do
  gem 'sentry-raven'
end
