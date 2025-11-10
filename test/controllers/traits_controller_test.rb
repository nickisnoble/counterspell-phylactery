require "test_helper"

class TraitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trait = traits(:one)

    # Set up authentication using the helper
    be_authenticated_as_admin!
  end

  test "should get index" do
    get traits_url
    assert_response :success
  end

  test "should get new" do
    get new_trait_url
    assert_response :success
  end

  test "should create trait" do
    assert_difference("Trait.count") do
      post traits_url, params: { 
        trait: { 
          abilities: '{"Test Ability": "Test description"}', 
          name: "Unique Test Trait", 
          type: "ANCESTRY",
          description: "A test trait for testing"
        } 
      }
    end

    assert_redirected_to trait_url(Trait.last)
  end

  test "should create trait with nested abilities hash" do
    assert_difference("Trait.count") do
      post traits_url, params: { 
        trait: { 
          abilities: {
            "Thick Skin" => "When you take Minor damage, you can mark 2 Stress instead of marking a Hit Point.",
            "Increased Fortitude" => "Spend 3 Hope to halve incoming physical damage."
          },
          name: "Vark Ancestry", 
          type: "ANCESTRY",
          description: "A trait with nested abilities"
        } 
      }
    end

    trait = Trait.last
    assert_redirected_to trait_url(trait)
    assert_equal "Thick Skin", trait.abilities.keys.first
    assert_equal "When you take Minor damage, you can mark 2 Stress instead of marking a Hit Point.", trait.abilities["Thick Skin"]
  end

  test "should update trait with nested abilities hash" do
    patch trait_url(@trait), params: { 
      trait: { 
        abilities: {
          "Updated Ability" => "Updated description",
          "Another Ability" => "Another description"
        },
        name: @trait.name,
        type: @trait.type
      } 
    }
    
    @trait.reload
    assert_redirected_to trait_url(@trait)
    assert_equal "Updated Ability", @trait.abilities.keys.first
    assert_equal "Updated description", @trait.abilities["Updated Ability"]
  end

  test "should show trait" do
    get trait_url(@trait)
    assert_response :success
  end

  test "should get edit" do
    get edit_trait_url(@trait)
    assert_response :success
  end

  test "should update trait" do
    patch trait_url(@trait), params: { trait: { abilities: @trait.abilities, name: @trait.name, slug: @trait.slug, type: @trait.type } }
    assert_redirected_to trait_url(@trait)
  end

  test "should destroy trait" do
    assert_difference("Trait.count", -1) do
      delete trait_url(@trait)
    end

    assert_redirected_to traits_url
  end
end
