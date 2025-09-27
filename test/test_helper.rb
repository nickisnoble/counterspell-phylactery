ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "rails/test_help"

require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def login_with_otp(email)
      post session_path, params: { email: email }

      user = User.find_by(email: email)
      code = user.auth_code

      post validate_session_path, params: { code: code }

      user
    end

    def be_authenticated!
      @user = User.create(email: "nick@miniware.team")
      login_with_otp(@user.email)
    end

    def be_authenticated_as_admin!
      be_authenticated!
      @user.admin!
    end
  end
end
