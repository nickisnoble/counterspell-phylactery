require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    skip("This is a placeholder and needs auth")
    get events_path
    assert_response :success
  end
end
