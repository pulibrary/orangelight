# frozen_string_literal: true
FactoryBot.define do
  factory :patron, class: 'Requests::Patron' do
    user { FactoryBot.build(:unauthenticated_patron) }
    patron_hash { {} }
    initialize_with { new(user:, patron_hash:) }
  end
end
