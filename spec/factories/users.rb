# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:username) { "username#{srand}" }
    sequence(:email) { "email-#{srand}@princeton.edu" }
    provider { 'cas' }
    password { 'foobarfoo' }
    uid(&:username)

    factory :valid_princeton_patron do
    end

    factory :invalid_princeton_patron do
    end

    factory :unauthorized_princeton_patron do
    end

    factory :valid_barcode_patron do
      provider { 'barcode' }
      sequence(:uid) { srand.to_s[2..15] }
      username { 'Barcode Patron' }
    end

    factory :unauthenticated_patron do
      guest { true }
      provider { nil }
    end

    # for patrons without a net ID
    factory :guest_patron do
      provider { 'barcode' }
      sequence(:uid) { srand.to_s[2..15] }
      sequence(:username) { "Student" }
    end
  end
end
