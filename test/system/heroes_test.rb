require "application_system_test_case"

class HeroesTest < ApplicationSystemTestCase
  setup do
    @hero = heroes(:one)
  end

  test "visiting the index" do
    visit heroes_url
    assert_selector "h1", text: "Heroes"
  end

  test "should create hero" do
    visit heroes_url
    click_on "New hero"

    fill_in "Ancestry", with: @hero.ancestry_id
    fill_in "Category", with: @hero.category
    fill_in "Name", with: @hero.name
    fill_in "Pronouns", with: @hero.pronouns
    fill_in "Role", with: @hero.role_id
    click_on "Create Hero"

    assert_text "Hero was successfully created"
    click_on "Back"
  end

  test "should update Hero" do
    visit hero_url(@hero)
    click_on "Edit this hero", match: :first

    fill_in "Ancestry", with: @hero.ancestry_id
    fill_in "Category", with: @hero.category
    fill_in "Name", with: @hero.name
    fill_in "Pronouns", with: @hero.pronouns
    fill_in "Role", with: @hero.role_id
    click_on "Update Hero"

    assert_text "Hero was successfully updated"
    click_on "Back"
  end

  test "should destroy Hero" do
    visit hero_url(@hero)
    accept_confirm { click_on "Destroy this hero", match: :first }

    assert_text "Hero was successfully destroyed"
  end
end
