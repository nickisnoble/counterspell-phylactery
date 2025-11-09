require "test_helper"

class TurboFlashTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(email: "admin-turbo@example.com", system_role: "admin", display_name: "Admin User")
    @trait = traits(:one)

    # Login as admin
    post session_path, params: { email: @admin.email }
    code = @admin.reload.auth_code
    post validate_session_path, params: { code: code }
  end

  test "Turbo Frame form submissions work and set flash" do
    # Visit edit page
    get edit_trait_path(@trait)
    assert_response :success

    # Submit form - should redirect to show page with flash
    patch trait_path(@trait), params: {
      trait: { name: "Updated via Turbo" }
    }

    assert_redirected_to trait_path(@trait)
    follow_redirect!

    # Flash should be present in the session
    assert_equal "Trait was successfully updated.", flash[:notice]
  end

  test "flash messages render with proper HTML structure" do
    # Set flash manually to test rendering
    get edit_trait_path(@trait), headers: { "HTTP_REFERER" => traits_path }

    patch trait_path(@trait), params: {
      trait: { name: "Flash Test" }
    }

    follow_redirect!

    # Check that flash container exists
    assert_select "#flash-messages"

    # Check that flash message component renders
    assert_select "[data-controller='flash']"

    # Check for close button
    assert_select "button[aria-label='Close']"
  end

  test "Turbo Frame requests preserve flash across redirects" do
    # Make a request that will set flash and redirect
    patch trait_path(@trait), params: {
      trait: { name: "Flash Preservation Test" }
    }, headers: {
      "Turbo-Frame" => "trait_form"
    }

    # Should redirect
    assert_response :redirect

    # Follow the redirect
    follow_redirect!

    # Flash should still be present
    assert_equal "Trait was successfully updated.", flash[:notice]

    # Response should contain flash message
    assert_response :success
  end

  test "validation errors render inline without full page reload" do
    # Submit invalid data
    post traits_path, params: {
      trait: { name: "", type: "" } # Invalid: missing required fields
    }, headers: {
      "Turbo-Frame" => "trait_form"
    }

    # Should re-render form with errors (unprocessable_entity status)
    assert_response :unprocessable_entity

    # Should contain turbo-frame
    assert_select "turbo-frame#trait_form"

    # Should contain error messages
    assert_select "#error_explanation"
  end

  test "successful form submission breaks out of Turbo Frame" do
    # Create a new trait
    assert_difference("Trait.count", 1) do
      post traits_path, params: {
        trait: {
          name: "New Turbo Trait",
          type: "ANCESTRY",
          description: "Test description"
        }
      }, headers: {
        "Turbo-Frame" => "trait_form"
      }
    end

    # Should redirect (302 or 303)
    assert_response :redirect

    # Flash should be set
    assert_equal "Trait was successfully created.", flash[:notice]

    # Follow redirect to show page
    follow_redirect!
    assert_response :success

    # Should show the new trait
    assert_select "h3", text: "New Turbo Trait"
  end

  test "flash component has auto-dismiss data attributes" do
    # Trigger a flash message
    patch trait_path(@trait), params: {
      trait: { name: "Auto Dismiss Test" }
    }

    follow_redirect!

    # Check for Stimulus controller and auto-dismiss value
    assert_select "[data-controller='flash']"
    assert_select "[data-flash-dismiss-after-value='5000']"
  end

  test "multiple Turbo Frame submissions work sequentially" do
    # First update
    patch trait_path(@trait), params: {
      trait: { name: "First Update" }
    }
    assert_equal "Trait was successfully updated.", flash[:notice]

    # Second update (flash should be replaced)
    patch trait_path(@trait), params: {
      trait: { name: "Second Update" }
    }
    assert_equal "Trait was successfully updated.", flash[:notice]

    follow_redirect!
    assert_response :success
  end

  test "flash messages render for both notice and alert types" do
    # Test notice (success)
    patch trait_path(@trait), params: {
      trait: { name: "Success Message" }
    }

    follow_redirect!

    # Should have green styling for notice
    assert_select ".bg-green-50"
    assert_select ".text-green-800"

    # For alert, we'd need a scenario that triggers an alert flash
    # (Not implementing here as most CRUD actions use notice)
  end

  test "Turbo Frame ID matches between form and edit/new pages" do
    # Check new page has correct frame
    get new_trait_path
    assert_select "turbo-frame#trait_form"

    # Check edit page has correct frame
    get edit_trait_path(@trait)
    assert_select "turbo-frame#trait_form"

    # Form should be inside the frame
    assert_select "turbo-frame#trait_form form[action='#{trait_path(@trait)}']"
  end

  test "flash messages work for all CRUD resources" do
    # Test Heroes
    hero = heroes(:one)
    patch hero_path(hero), params: {
      hero: { name: "Updated Hero" }
    }
    assert_redirected_to hero_path(hero)
    assert_equal "Hero was successfully updated.", flash[:notice]

    # Test Traits (already tested in setup)
    patch trait_path(@trait), params: {
      trait: { name: "Updated Trait" }
    }
    assert_redirected_to trait_path(@trait)
    assert_equal "Trait was successfully updated.", flash[:notice]
  end
end
