require "test_helper"

# These tests are kept for future reference but AJAX trait creation
# has been removed from the hero form to simplify the UI.
# Traits should now be created through the standard traits form.
class TraitsAjaxTest < ActionDispatch::IntegrationTest
  setup do
    # Set up authentication using the helper
    @admin_user = User.create!(email: "admin@example.com", system_role: "admin")
    login_with_otp("admin@example.com")
  end

  # Note: This JSON API is kept for potential future use but is no longer
  # used by the hero form which now uses dropdown selection only
  test "JSON API still works for trait creation" do
    assert_difference("Trait.count") do
      post traits_url,
           params: {
             trait: {
               type: "ANCESTRY",
               name: "Dwarf",
               description: "Short and sturdy folk",
               abilities: '{"Darkvision": "See in darkness", "Resilience": "Resist poison"}'
             }
           },
           headers: { 'Accept': "application/json" }
    end

    assert_response :created

    # Verify JSON response structure
    response_data = JSON.parse(response.body)
    assert response_data["success"]
    assert_equal "Dwarf", response_data["trait"]["name"]
    assert_equal "ANCESTRY", response_data["trait"]["type"]
    assert response_data["trait"]["id"]

    # Verify trait was actually created with correct data
    trait = Trait.last
    assert_equal "Dwarf", trait.name
    assert_equal "ANCESTRY", trait.type
    assert_equal "Short and sturdy folk", trait.description

    # Verify abilities were stored (JSON parsing handled by model)
    assert_not_nil trait.abilities
  end

  test "JSON API returns error when trait creation fails" do
    assert_no_difference("Trait.count") do
      post traits_url,
           params: {
             trait: {
               type: "", # Missing required type
               name: "Invalid Trait",
               description: "This should fail",
               abilities: "{}"
             }
           },
           headers: { 'Accept': "application/json" }
    end

    assert_response :unprocessable_content

    response_data = JSON.parse(response.body)
    assert_not response_data["success"]
    assert response_data["errors"]
    assert response_data["errors"].any? { |error| error.include?("Type") }
  end

  test "JSON API handles malformed JSON in abilities gracefully" do
    assert_difference("Trait.count") do
      post traits_url,
           params: {
             trait: {
               type: "BACKGROUND",
               name: "Test Background",
               description: "Test description",
               abilities: "not valid json"
             }
           },
           headers: { 'Accept': "application/json" }
    end

    assert_response :created
    trait = Trait.last
    # Should handle the malformed JSON without crashing
    assert_equal "Test Background", trait.name
  end
end
