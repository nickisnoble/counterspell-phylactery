require "application_system_test_case"

class TraitsTest < ApplicationSystemTestCase
  setup do
    @trait = traits(:one)
  end

  test "visiting the index" do
    visit traits_url
    assert_selector "h1", text: "Traits"
  end

  test "should create trait" do
    visit traits_url
    click_on "New trait"

    fill_in "Abilities", with: @trait.abilities
    fill_in "Name", with: @trait.name
    fill_in "Slug", with: @trait.slug
    fill_in "Type", with: @trait.type
    click_on "Create Trait"

    assert_text "Trait was successfully created"
    click_on "Back"
  end

  test "should update Trait" do
    visit trait_url(@trait)
    click_on "Edit this trait", match: :first

    fill_in "Abilities", with: @trait.abilities
    fill_in "Name", with: @trait.name
    fill_in "Slug", with: @trait.slug
    fill_in "Type", with: @trait.type
    click_on "Update Trait"

    assert_text "Trait was successfully updated"
    click_on "Back"
  end

  test "should destroy Trait" do
    visit trait_url(@trait)
    accept_confirm { click_on "Destroy this trait", match: :first }

    assert_text "Trait was successfully destroyed"
  end
end
