# frozen_string_literal: true
namespace :admins do
  desc 'Update the list of admin users for the app'
  task update: :environment do
    if ENV["ORANGELIGHT_ADMIN_NETIDS"]
      # set all existing admins back to false, to catch any that shouldn't be admins any more
      puts "Removing existing admins"
      current_admins = User.where(admin: true)
      current_admins.each do |user|
        user.admin = false
        user.save!
      end
      puts "Adding admins from ORANGELIGHT_ADMIN_NETIDS"
      admin_netids = ENV["ORANGELIGHT_ADMIN_NETIDS"].split(" ")
      admin_netids.each do |netid|
        user = User.find_by(uid: netid)
        if user
          user.admin = true
          user.save!
        end
      end
    else
      puts "Environment variable ORANGELIGHT_ADMIN_NETIDS must be set!"
    end
  end
end
