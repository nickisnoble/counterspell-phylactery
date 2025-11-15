require "test_helper"

class Dashboard::LocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(email: "admin@test.com", system_role: "admin", display_name: "Admin")
    @player = User.create!(email: "player@test.com", system_role: "player", display_name: "Player")
    @location = Location.create!(name: "Test Venue", address: "123 Test St")
  end

  test "requires admin authentication" do
    get dashboard_locations_path
    assert_redirected_to new_session_path
  end

  test "redirects non-admin users" do
    sign_in_as @player
    get dashboard_locations_path
    assert_redirected_to root_path
  end

  test "index displays locations for admins" do
    sign_in_as @admin
    get dashboard_locations_path
    assert_response :success
  end

  test "new displays form for admins" do
    sign_in_as @admin
    get new_dashboard_location_path
    assert_response :success
  end

  test "create creates location and redirects" do
    sign_in_as @admin
    assert_difference("Location.count") do
      post dashboard_locations_path, params: { location: { name: "New Venue", address: "123 New St" } }
    end
    assert_redirected_to dashboard_locations_path
  end

  test "edit displays form for admins" do
    sign_in_as @admin
    get edit_dashboard_location_path(@location)
    assert_response :success
  end

  test "update updates location and redirects" do
    sign_in_as @admin
    patch dashboard_location_path(@location), params: { location: { name: "Updated Name" } }
    assert_redirected_to dashboard_locations_path
    assert_equal "Updated Name", @location.reload.name
  end

  test "destroy deletes location and redirects" do
    sign_in_as @admin
    assert_difference("Location.count", -1) do
      delete dashboard_location_path(@location)
    end
    assert_redirected_to dashboard_locations_path
  end

  private

  def sign_in_as(user)
    login_with_otp(user.email)
  end
end
