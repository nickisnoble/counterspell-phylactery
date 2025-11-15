require "simplecov"
SimpleCov.start "rails" do
  add_filter "/test/"
  add_filter "/config/"
  add_filter "/vendor/"
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # Disable parallelization when running coverage to get accurate results
    parallelize(workers: ENV["COVERAGE"] ? 1 : :number_of_processors)

    # Setup unique test data for each parallel worker
    parallelize_setup do |worker|
      # Each worker gets a unique namespace to avoid collisions
      @worker_id = worker
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # IMPORTANT: Do not use user fixtures (users.yml) in tests!
    # The User model has encrypted OTP secrets which cannot be properly set in fixtures.
    # Instead, create users directly in your test setup using User.create!
    # Example: @user = User.create!(email: "test@example.com", system_role: "player")
    # Then use login_with_otp(@user.email) to authenticate in tests.

    def login_with_otp(email)
      post session_path, params: { email: email }

      user = User.find_by(email: email)
      code = user.auth_code

      post validate_session_path, params: { code: code }

      user
    end

    def be_authenticated!
      # Use unique email per parallel worker to avoid collisions
      worker_suffix = defined?(@worker_id) ? @worker_id : 0
      @user = User.create!(email: "test-#{worker_suffix}-#{SecureRandom.hex(4)}@example.com")
      login_with_otp(@user.email)
    end

    def be_authenticated_as_admin!
      # Use unique email per parallel worker to avoid collisions
      worker_suffix = defined?(@worker_id) ? @worker_id : 0
      @user = User.create!(email: "admin-#{worker_suffix}-#{SecureRandom.hex(4)}@example.com", system_role: "admin")
      login_with_otp(@user.email)
    end

    def be_authenticated_as_gm!
      # Use unique email per parallel worker to avoid collisions
      worker_suffix = defined?(@worker_id) ? @worker_id : 0
      @user = User.create!(email: "gm-#{worker_suffix}-#{SecureRandom.hex(4)}@example.com", system_role: "gm")
      login_with_otp(@user.email)
    end
  end
end
