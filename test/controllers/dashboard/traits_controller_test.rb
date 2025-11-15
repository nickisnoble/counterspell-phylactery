require "test_helper"

class Dashboard::TraitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trait = traits(:one)

    # Set up authentication using the helper
    be_authenticated_as_admin!
  end

  test "should get index" do
    get dashboard_traits_url
    assert_response :success
    assert_select "article" # Verify cards are rendered
  end

  test "should get new" do
    get new_dashboard_trait_url
    assert_response :success
  end

  test "should create trait" do
    assert_difference("Trait.count") do
      post dashboard_traits_url, params: {
        trait: {
          abilities: '{"Test Ability": "Test description"}',
          name: "Unique Test Trait",
          type: "ANCESTRY",
          description: "A test trait for testing"
        }
      }
    end

    assert_redirected_to dashboard_trait_url(Trait.last)
  end

  test "should create trait with nested abilities hash" do
    assert_difference("Trait.count") do
      post dashboard_traits_url, params: {
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
    assert_redirected_to dashboard_trait_url(trait)
    assert_equal "Thick Skin", trait.abilities.keys.first
    assert_equal "When you take Minor damage, you can mark 2 Stress instead of marking a Hit Point.", trait.abilities["Thick Skin"]
  end

  test "should update trait with nested abilities hash" do
    patch dashboard_trait_url(@trait), params: {
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
    assert_redirected_to dashboard_trait_url(@trait)
    assert_equal "Updated Ability", @trait.abilities.keys.first
    assert_equal "Updated description", @trait.abilities["Updated Ability"]
  end

  test "should show trait" do
    get dashboard_trait_url(@trait)
    assert_response :success
    assert_select "article" # Verify card is rendered
    assert_select "h3", text: @trait.name
  end

  test "should get edit" do
    get edit_dashboard_trait_url(@trait)
    assert_response :success
  end

  test "should update trait" do
    patch dashboard_trait_url(@trait), params: { trait: { abilities: @trait.abilities, name: @trait.name, slug: @trait.slug, type: @trait.type } }
    assert_redirected_to dashboard_trait_url(@trait)
  end

  test "should destroy trait" do
    assert_difference("Trait.count", -1) do
      delete dashboard_trait_url(@trait)
    end

    assert_redirected_to dashboard_traits_url
  end

  # GM Permission Tests
  test "GMs can view traits index" do
    be_authenticated_as_gm!
    get dashboard_traits_url
    assert_response :success
  end

  test "GMs can view individual trait" do
    be_authenticated_as_gm!
    get dashboard_trait_url(@trait)
    assert_response :success
  end

  test "GMs cannot access new trait form" do
    be_authenticated_as_gm!
    get new_dashboard_trait_url
    assert_redirected_to root_path
    assert_equal "Admin access required", flash[:alert]
  end

  test "GMs cannot create traits" do
    be_authenticated_as_gm!
    assert_no_difference("Trait.count") do
      post dashboard_traits_url, params: {
        trait: {
          name: "Test Trait",
          type: "ANCESTRY",
          description: "Test"
        }
      }
    end
    assert_redirected_to root_path
  end

  test "GMs cannot access edit trait form" do
    be_authenticated_as_gm!
    get edit_dashboard_trait_url(@trait)
    assert_redirected_to root_path
    assert_equal "Admin access required", flash[:alert]
  end

  test "GMs cannot update traits" do
    be_authenticated_as_gm!
    original_name = @trait.name
    patch dashboard_trait_url(@trait), params: {
      trait: { name: "Changed Name" }
    }
    assert_redirected_to root_path
    @trait.reload
    assert_equal original_name, @trait.name
  end

  test "GMs cannot destroy traits" do
    be_authenticated_as_gm!
    assert_no_difference("Trait.count") do
      delete dashboard_trait_url(@trait)
    end
    assert_redirected_to root_path
  end
end
