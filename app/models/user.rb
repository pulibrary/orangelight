# frozen_string_literal: true

class User < ApplicationRecord
  validates :username, presence: true
  validates :uid, length: { is: 14 }, format: { with: /\A([\d]{14})\z/ },
                  if: :barcode_provider?

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable,
         :trackable, :omniauthable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  # @return [String] the user name
  def to_s
    username || 'User'
  end

  # Determines whether or not this is a user which has an identifiable barcode
  # @return [TrueClass, FalseClass]
  def barcode_provider?
    provider == 'barcode'
  end

  # Retrieves a user authenticated using the CAS
  # @param access_token []
  # @return [User,nil]
  def self.from_cas(access_token)
    User.where(provider: access_token.provider, uid: access_token.uid).first_or_create do |user|
      user.uid = access_token.uid
      user.username = access_token.uid
      user.email = "#{access_token.uid}@princeton.edu"
      user.password = SecureRandom.urlsafe_base64
      user.provider = access_token.provider
    end
  end

  # Retrieves a user authenticated using a barcode
  # @param access_token [] access token containing the barcode accessed using #uid
  # @return [User,nil]
  def self.from_barcode(access_token)
    User.where(provider: access_token.provider, uid: access_token.uid,
               username: access_token.info.last_name).first_or_initialize do |user|
      user.uid = access_token.uid
      user.username = access_token.info.last_name
      user.email = access_token.uid
      user.password = SecureRandom.urlsafe_base64
      user.provider = access_token.provider
    end
  end

  # Alternative to the implementation used in devise-guests, due to memory use
  # problems when running that task
  # https://github.com/cbeer/devise-guests/blob/7ab8c55d7a2b677ce61cc83486d6e3723d8795b2/lib/railties/devise_guests.rake
  def self.expire_guest_accounts
    User
      .where("guest = ? and updated_at < ?", true, Time.now.utc - 7.days)
      .find_each(batch_size: 25_000, &:destroy)
  end
end
