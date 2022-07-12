# frozen_string_literal: true
require 'rails_helper'

describe Bookmark do
  it 'allows user to create 5 bookmarks' do
    user = user_with_many_bookmarks(5)
    expect { user.save! }.not_to raise_error(ActiveRecord::RecordInvalid)
    expect(user.bookmarks.count).to eq(5)
  end
  it 'does not allow user to create more than 1000 bookmarks' do
    user = user_with_many_bookmarks(1001)
    expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  def user_with_many_bookmarks(count)
    user = FactoryBot.build(:unauthenticated_patron)
    (1..count).each do |document_id|
      bookmark = Bookmark.new
      bookmark.user = user
      bookmark.document_id = document_id
      user.bookmarks << bookmark
    end
    user
  end
end
