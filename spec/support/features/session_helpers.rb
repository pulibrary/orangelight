# frozen_string_literal: true

module Features
  # Provides methods for login and logout within Feature Tests
  module SessionHelpers
    include Warden::Test::Helpers
    # Regular login
    def login_as(user)
      user.reload # because the user isn't re-queried via Warden
      super(user, scope: :user, run_callbacks: false)
    end

    # Regular logout
    def logout(user = :user)
      super(user)
    end

    # Poltergeist-friendly sign-up
    # Use this in feature tests
    def sign_up_with(email, password)
      Capybara.exact = true
      visit new_user_registration_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', with: password
      click_button 'Sign up'
    end
  end
end
