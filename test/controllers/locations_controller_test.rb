require "test_helper"

class LocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @location = Location.create!(name: "Test Venue", address: "123 Test St")
  end

  test "should get index" do
    get locations_path
    assert_response :success
  end

  test "should show location" do
    get location_path(@location)
    assert_response :success
  end

  test "should show location with upcoming and past events" do
    @event1 = Event.create!(
      name: "Upcoming Event",
      date: 7.days.from_now,
      location: @location,
      status: "upcoming"
    )
    @event2 = Event.create!(
      name: "Past Event",
      date: 7.days.ago,
      location: @location,
      status: "past"
    )

    get location_path(@location)
    assert_response :success
  end
end
