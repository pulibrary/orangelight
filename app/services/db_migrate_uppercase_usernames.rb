# frozen_string_literal: false

class DBMigrateUppercaseUsernames
  def self.run
    find_uppercase_users.map { |uppercase_user|
      find_lowercase_user(uppercase_user).map { |lowercase_user|
        merge_bookmarks(uppercase_user, lowercase_user)
        merge_searches(uppercase_user, lowercase_user)
        delete_uppercase_user(uppercase_user)
      }
    }
  end

  # find all users with uppercase letters in their username
  def find_uppercase_users
    User.where("uid ~ ?", "[A-Z]").to_a
  end

  # find lowercase version of the user with uppercase letters in their username
  def find_lowercase_user(uppercase_user)
    User.find_by(username: uppercase_user.uid.downcase)
  end

  # merge uppercase user's bookmarks into lowercase user's bookmarks
  def merge_bookmarks(uppercase_user, lowercase_user)
    uppercase_user_bookmarks = Bookmark.where(user_id: uppercase_user.id)
    lowercase_user_bookmarks = Bookmark.where(user_id: lowercase_user.id)
    lowercase_user.bookmarks = uppercase_user_bookmarks | lowercase_user_bookmarks
  end

  # merge uppercase user's searches into lowercase user's searches
  def merge_searches(uppercase_user, lowercase_user)
    uppercase_user_searches = Search.where(user_id: uppercase_user.id)
    lowercase_user_searches = Search.where(user_id: lowercase_user.id)
    lowercase_user.searches = uppercase_user_searches | lowercase_user_searches
  end

  # delete the duplicate account
  def delete_uppercase_user(uppercase_user)
    uppercase_user.destroy
  end
end
