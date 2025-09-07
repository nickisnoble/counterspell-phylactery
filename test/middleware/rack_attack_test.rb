require "test_helper"

class RackAttackTest < ActionDispatch::IntegrationTest
  include Rack::Test::Methods

  def app
    Rails.application
  end

  setup do
    Rails.cache.clear
  end

  test "blocks WordPress scanner requests" do
    blocked_paths = [
      "/wp-admin",
      "/wp-login.php",
      "/xmlrpc.php",
      "/wp-content/uploads/malware.php"
    ]

    blocked_paths.each do |path|
      get path
      assert_equal 403, last_response.status, "Expected #{path} to be blocked"
      assert_match "Blocked: This site is not WordPress", last_response.body
    end
  end

  test "tracks and blocks IPs with multiple WordPress requests" do
    ip = "1.2.3.4"
    path = "/wp-login.php"

    2.times do
      get path, {}, "REMOTE_ADDR" => ip
      assert_equal 403, last_response.status, "Expected #{path} to be blocked"
    end

    # Simulate a new request after the IP is blocked
    get path, {}, "REMOTE_ADDR" => ip
    assert_equal 403, last_response.status, "Expected IP #{ip} to be blocked"
  end

  test "blocks PHP file access attempts" do
    get "/any.php"
    assert_equal 404, last_response.status, "Expected .php file access to be blocked"
    assert_match "Not Found", last_response.body
  end

  test "blocks requests with bad user-agent strings" do
    bad_user_agents = [
      "masscan", "nikto", "nmap", "sqlmap", "wget", "curl", "python-requests"
    ]

    bad_user_agents.each do |agent|
      get "/", {}, { "HTTP_USER_AGENT" => agent }
      assert_equal 403, last_response.status, "Expected requests with User-Agent #{agent} to be blocked"
      assert_match "Forbidden", last_response.body
    end
  end
end
