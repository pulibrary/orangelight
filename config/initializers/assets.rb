# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

bl_dir = Bundler.rubygems.find_name('blacklight').first.full_gem_path
assets_path = File.join(bl_dir, 'app', 'javascript')
Rails.application.config.assets.paths << assets_path
