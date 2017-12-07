class User < ApplicationRecord
  # include Blacklight::Folders::User
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
  def to_s
    username || 'User'
  end

  def barcode_provider?
    provider == 'barcode'
  end

  def self.from_cas(access_token)
    User.where(provider: access_token.provider, uid: access_token.uid).first_or_create do |user|
      user.uid = access_token.uid
      user.username = access_token.uid
      user.email = "#{access_token.uid}@princeton.edu"
      user.password = SecureRandom.urlsafe_base64
      user.provider = access_token.provider
    end
  end

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
end
