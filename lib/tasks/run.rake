namespace :run do
  desc 'Tell Sidekiq to run Banner Syncinator immediately'
  task(:nowish) do
    require './lib/banner_syncinator'
    require 'sidekiq'
    require 'sidetiq'

    BannerSyncinator.initialize!

    BannerSyncinator::Worker.perform_async
  end
end