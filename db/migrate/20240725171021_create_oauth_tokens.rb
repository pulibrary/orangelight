# frozen_string_literal: true

class CreateOAuthTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :oauth_tokens do |t|
      t.string :service, null: false
      t.string :endpoint, null: false
      t.string :token
      t.datetime :expiration_time

      t.timestamps
    end

    add_index :oauth_tokens, :service, unique: true
    add_index :oauth_tokens, :endpoint, unique: true
  end
end
