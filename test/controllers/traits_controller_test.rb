require "test_helper"

class TraitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trait = traits(:one)
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
      post traits_url, params: { trait: { abilities: @trait.abilities, name: @trait.name, slug: @trait.slug, type: @trait.type } }
    end

    assert_redirected_to trait_url(Trait.last)
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
