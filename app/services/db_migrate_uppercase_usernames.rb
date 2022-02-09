# frozen_string_literal: false

class DBMigrateUppercaseUsernames
  def self.run
    new.run
  end

  def run
    find_uppercase_users.map { |uppercase_user| UserLowercaser.new(uppercase_user).convert }
  end

  # find all users with uppercase letters in their username
  def find_uppercase_users
    User.where("uid ~ ?", "[A-Z]").to_a
  end

  class UserLowercaser
    attr_reader :uppercase_user

    def initialize(uppercase_user)
      @uppercase_user = uppercase_user
    end

    def convert
      lowercase_user = find_lowercase_user
      merge_bookmarks(lowercase_user)
      merge_searches(lowercase_user)
    end

    # find lowercase version of the user with uppercase letters in their username
    def find_lowercase_user
      User.find_by(username: uppercase_user.uid.downcase) || User.create(uid: uppercase_user.uid.downcase, username: uppercase_user.uid.downcase)
    end

    # merge uppercase user's bookmarks into lowercase user's bookmarks
    def merge_bookmarks(lowercase_user)
      uppercase_user_bookmarks = Bookmark.where(user_id: uppercase_user.id)
      lowercase_user_bookmarks = Bookmark.where(user_id: lowercase_user.id).to_a
      lowercase_bookmarks_doc_ids = lowercase_user_bookmarks.map(&:document_id)
      lowercase_user.bookmarks = lowercase_user_bookmarks + uppercase_user_bookmarks.reject { |bookmark| lowercase_bookmarks_doc_ids.include? bookmark.document_id }
    end

    # merge uppercase user's searches into lowercase user's searches
    def merge_searches(lowercase_user)
      uppercase_user_searches = Search.where(user_id: uppercase_user.id)
      lowercase_user_searches = Search.where(user_id: lowercase_user.id).to_a
      lowercase_searches_queries = lowercase_user_searches.map(&:query_params)
      lowercase_user.searches = lowercase_user_searches + uppercase_user_searches.reject { |search| lowercase_searches_queries.include? search.query_params }
    end
  end
end
