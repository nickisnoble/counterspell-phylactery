require "test_helper"

class LocationTest < ActiveSupport::TestCase
  test "requires name" do
    location = Location.new(address: "123 Main St")
    assert_not location.valid?
    assert_includes location.errors[:name], "can't be blank"
  end

  test "requires address" do
    location = Location.new(name: "The Tavern")
    assert_not location.valid?
    assert_includes location.errors[:address], "can't be blank"
  end

  test "generates slug from name" do
    location = Location.create!(name: "The Dragon's Lair", address: "123 Quest Rd")
    assert_equal "the-dragon-s-lair", location.slug
  end

  test "validates name uniqueness case-insensitively" do
    Location.create!(name: "Unique Location", address: "123 Main St")
    duplicate = Location.new(name: "unique location", address: "456 Other St")
    assert_not duplicate.valid?
  end

  test "has rich text about field" do
    location = Location.create!(name: "Test Location", address: "123 Test St")
    assert_respond_to location, :about
    assert location.about.is_a?(ActionText::RichText) || location.about.nil?
  end
end
