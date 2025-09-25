require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should only work for admins" do
    skip("later.")
    get dashboard_url
    assert_response :success
  end
end
