source 'https://rubygems.org'

gem 'actionpack', '~> 3.2.22' # apparently needed by exception_notification
gem 'oj', '~> 2.8.1'
gem 'rails_config', '~> 0.3.3'
gem 'rake', '~> 10.2.2'
gem 'sidekiq', '~> 3.5.0'
gem 'sidekiq-cron', '~> 0.3.1'
gem 'trogdir_api_client', '~> 0.7.0'
# Until a new gem is released > 1.1.3
# See: https://github.com/mwunsch/weary/pull/47
gem 'weary', github: 'biola/weary', branch: 'preserve_empty_params'

group :development, :staging, :production do
  gem 'ruby-oci8', '~> 2.2.2'
end

group :development, :test do
  gem 'pry', '~> 0.9.12'
  gem 'pry-rescue', '~> 1.4.0'
  gem 'pry-stack_explorer', '~> 0.4.9'
  gem 'rspec', '~> 2.14.1'
end

group :test do
  gem 'webmock', '~> 1.17.4'
  gem 'factory_girl', '~> 4.4.0'
  gem 'faker', '~> 1.3.0'
  gem 'trogdir_api', '~> 0.4.0'
end

group :production do
  gem 'sentry-raven', '~> 0.12.3'
end
