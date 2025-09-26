require "test_helper"

class HeroesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @hero = heroes(:one)
    @ancestry_trait = traits(:ancestry)
    @background_trait = traits(:background) 
    @class_trait = traits(:class_trait)
    
    # Set up authentication using the helper
    @admin_user = User.create!(email: "admin@example.com", system_role: "admin")
    login_with_otp("admin@example.com")
  end

  test "should get index" do
    get heroes_url
    assert_response :success
  end

  test "should get new" do
    get new_hero_url
    assert_response :success
  end

  test "should create hero without traits and expect validation failure" do
    # Hero creation should fail validation because required traits are missing
    assert_no_difference("Hero.count") do
      post heroes_url, params: { 
        hero: { 
          name: "Unique Hero Name", 
          pronouns: "They/Them", 
          role: "fighter" 
        } 
      }
    end

    assert_response :unprocessable_entity
    assert_match /must include Ancestry/, response.body
    assert_match /must include Background/, response.body  
    assert_match /must include Class/, response.body
  end

  test "should create hero and associate selected traits" do
    assert_difference("Hero.count") do
      post heroes_url, params: { 
        hero: { 
          name: "Hero With Unique Traits #{Time.current.to_i}", 
          pronouns: "She/Her", 
          role: "strategist" 
        },
        trait_ids_ancestry: @ancestry_trait.id,
        trait_ids_background: @background_trait.id,
        trait_ids_class: @class_trait.id
      }
    end

    hero = Hero.last
    assert_redirected_to hero_url(hero)
    
    # Verify trait associations
    assert_equal 3, hero.traits.count
    assert_includes hero.traits, @ancestry_trait
    assert_includes hero.traits, @background_trait  
    assert_includes hero.traits, @class_trait
    
    # Verify one trait of each required type
    ancestry_traits = hero.traits.where(type: "ANCESTRY")
    background_traits = hero.traits.where(type: "BACKGROUND")
    class_traits = hero.traits.where(type: "CLASS")
    
    assert_equal 1, ancestry_traits.count
    assert_equal 1, background_traits.count
    assert_equal 1, class_traits.count
  end

  test "should show hero" do
    get hero_url(@hero)
    assert_response :success
  end

  test "should get edit" do
    get edit_hero_url(@hero)
    assert_response :success
  end

  test "should update hero" do
    patch hero_url(@hero), params: { 
      hero: { 
        name: "Updated Name", 
        pronouns: "They/Them", 
        role: "wild_card" 
      } 
    }
    
    assert_redirected_to hero_url(@hero)
    @hero.reload
    assert_equal "Updated Name", @hero.name
    assert_equal "They/Them", @hero.pronouns
    assert_equal "wild_card", @hero.role
  end

  test "should destroy hero" do
    assert_difference("Hero.count", -1) do
      delete hero_url(@hero)
    end

    assert_redirected_to heroes_url
  end

  test "should handle trait parameter parsing correctly" do
    # Test that trait IDs are properly extracted from form parameters
    # This test expects validation failure because background trait is missing
    assert_no_difference("Hero.count") do
      post heroes_url, params: { 
        hero: { 
          name: "Trait Parse Test #{Time.current.to_i}", 
          pronouns: "He/Him", 
          role: "fighter" 
        },
        trait_ids_ancestry: @ancestry_trait.id.to_s,
        trait_ids_background: "", # Empty should be ignored, causing validation failure
        trait_ids_class: @class_trait.id.to_s
      }
    end

    assert_response :unprocessable_entity
    assert_match /must include Background/, response.body
  end
end
