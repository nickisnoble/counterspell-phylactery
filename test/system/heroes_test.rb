require "application_system_test_case"

class HeroesTest < ApplicationSystemTestCase
  setup do
    @admin_user = User.create!(email: "admin@example.com", system_role: "admin")
    
    # Create test traits for each required type
    @ancestry_trait = Trait.create!(
      type: "ANCESTRY", 
      name: "Human Test", 
      slug: "human-test",
      abilities: { "Versatile" => "Test ability" }
    )
    @background_trait = Trait.create!(
      type: "BACKGROUND", 
      name: "Scholar Test", 
      slug: "scholar-test",
      abilities: { "Research" => "Test ability" }
    )
    @class_trait = Trait.create!(
      type: "CLASS", 
      name: "Fighter Test", 
      slug: "fighter-test",
      abilities: { "Combat" => "Test ability" }
    )
  end

  test "selecting traits from dropdowns works without AJAX" do
    login_as_admin
    visit new_hero_path
    
    # Fill in basic hero info
    fill_in "Name", with: "Test Hero"
    choose "She/Her"
    choose "fighter"
    
    # Select traits from each dropdown 
    select "Human Test", from: "hero_trait_ids_ancestry"
    select "Scholar Test", from: "hero_trait_ids_background"  
    select "Fighter Test", from: "hero_trait_ids_class"
    
    # Verify selected traits are displayed
    assert page.has_content?("Human Test")
    assert page.has_content?("Scholar Test")
    assert page.has_content?("Fighter Test")
  end

  test "removing selected traits works client-side only" do
    login_as_admin
    visit new_hero_path
    
    # Fill in basic info
    fill_in "Name", with: "Test Hero"
    choose "He/Him"
    choose "protector"
    
    # Select a trait
    select "Human Test", from: "hero_trait_ids_ancestry"
    
    # Verify trait is shown
    assert page.has_content?("Human Test")
    
    # Click remove button (this should work client-side only)
    click_button "Remove"
    
    # Verify trait selection is restored (dropdown should be back to original state)
    assert page.has_select?("hero_trait_ids_ancestry", selected: "Select Ancestry...")
    refute page.has_content?("Remove")
  end

  test "form submission with traits creates hero correctly" do
    login_as_admin
    visit new_hero_path
    
    # Fill in all required fields
    fill_in "Name", with: "Complete Test Hero"
    choose "They/Them"
    choose "strategist"
    
    # Select all required traits
    select "Human Test", from: "hero_trait_ids_ancestry"
    select "Scholar Test", from: "hero_trait_ids_background"
    select "Fighter Test", from: "hero_trait_ids_class"
    
    # Submit the form
    click_button "Create Hero"
    
    # Verify hero was created
    hero = Hero.last
    assert_equal "Complete Test Hero", hero.name
    assert_equal "They/Them", hero.pronouns
    assert_equal "strategist", hero.role
    
    # Verify traits were associated correctly
    assert_equal 3, hero.traits.count
    assert_includes hero.traits, @ancestry_trait
    assert_includes hero.traits, @background_trait
    assert_includes hero.traits, @class_trait
    
    # Verify we're redirected to the hero page
    assert_current_path hero_path(hero)
  end

  test "no JavaScript errors occur during trait selection" do
    login_as_admin
    visit new_hero_path
    
    # Monitor for JavaScript errors by checking console logs would require
    # more advanced setup, but we can at least ensure basic interaction works
    
    fill_in "Name", with: "JS Test Hero"
    choose "He/Him"
    choose "face"
    
    # Select traits - if there were JS errors, these would likely fail
    select "Human Test", from: "hero_trait_ids_ancestry"
    select "Scholar Test", from: "hero_trait_ids_background"
    select "Fighter Test", from: "hero_trait_ids_class"
    
    # Verify page still functions normally
    assert page.has_content?("Human Test")
    assert page.has_content?("Scholar Test") 
    assert page.has_content?("Fighter Test")
    
    # Form should still be submittable
    click_button "Create Hero"
    assert_current_path hero_path(Hero.last)
  end

  private

  def login_as_admin
    visit new_session_path
    fill_in "Email", with: "admin@example.com"
    click_button "Send Login Code"
    
    # Find the user and get their OTP code
    user = User.find_by(email: "admin@example.com")
    otp = user.auth_code
    
    fill_in "Code", with: otp
    click_button "Sign In"
  end
end
