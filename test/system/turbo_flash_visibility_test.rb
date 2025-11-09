require "application_system_test_case"

class TurboFlashVisibilityTest < ApplicationSystemTestCase
  setup do
    @admin = User.create!(email: "turbo-test@example.com", system_role: "admin", display_name: "Admin")
    @trait = traits(:one)

    # Login
    visit new_session_path
    fill_in "email", with: @admin.email
    click_button "Start your Journey"

    code = @admin.reload.auth_code
    fill_in "code", with: code
    click_button "Verify"
  end

  test "flash message is visible after Turbo Frame form submission without page reload" do
    visit edit_trait_path(@trait)

    # Add a data attribute to body to track if page reloads
    page.execute_script("document.body.setAttribute('data-test-marker', 'original')")

    # Fill in and submit form
    fill_in "Name", with: "Turbo Test Update"
    click_button "Update Trait"

    # Wait for navigation to complete
    sleep 0.5

    # CRITICAL: Verify flash message is VISIBLE on the page
    assert page.has_selector?("#notice_flash", text: "Trait was successfully updated", visible: true, wait: 2),
      "Flash message should be visible after Turbo form submission"

    # CRITICAL: Verify page did NOT reload (our marker should still be there)
    marker = page.evaluate_script("document.body.getAttribute('data-test-marker')")
    assert_equal "original", marker, "Page should NOT have reloaded (Turbo navigation only)"
  end
end
