require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "admins can access dashboard" do
    be_authenticated_as_admin!
    get dashboard_url
    assert_response :success
  end

  test "GMs can access dashboard" do
    be_authenticated_as_gm!
    get dashboard_url
    assert_response :success
  end

  test "regular users cannot access dashboard" do
    be_authenticated!
    get dashboard_url
    assert_redirected_to root_path
    assert_equal "GM or Admin access required", flash[:alert]
  end

  test "unauthenticated users cannot access dashboard" do
    get dashboard_url
    assert_redirected_to new_session_path
  end
end
