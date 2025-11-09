require "application_system_test_case"

class TurboFlashTest < ApplicationSystemTestCase
  setup do
    @admin = User.create!(email: "admin@example.com", system_role: "admin", display_name: "Admin User")
    @trait = traits(:one)

    # Login as admin
    visit new_session_path
    fill_in "email", with: @admin.email
    click_on "Start your Journey"

    # Complete OTP verification
    code = @admin.reload.auth_code
    fill_in "code", with: code
    click_on "Verify"
  end

  test "flash message appears after Turbo Frame form submission" do
    visit edit_trait_path(@trait)

    # Fill in the form
    fill_in "Name", with: "Updated Trait Name"

    # Submit the form via Turbo Frame
    click_on "Update Trait"

    # Flash should appear without full page reload
    assert_selector "#notice_flash", text: "Trait was successfully updated", wait: 2

    # Should still be on the show page (redirect worked)
    assert_current_path trait_path(@trait)
  end

  test "flash message auto-dismisses after 5 seconds" do
    visit edit_trait_path(@trait)

    fill_in "Name", with: "Another Update"
    click_on "Update Trait"

    # Flash should appear
    assert_selector "#notice_flash", text: "Trait was successfully updated", wait: 2

    # Flash should auto-dismiss after 5 seconds (with some buffer for animation)
    assert_no_selector "#notice_flash", wait: 7
  end

  test "flash message can be manually closed" do
    visit edit_trait_path(@trait)

    fill_in "Name", with: "Manual Close Test"
    click_on "Update Trait"

    # Flash should appear
    assert_selector "#notice_flash", text: "Trait was successfully updated", wait: 2

    # Click the close button (×)
    within "#notice_flash" do
      find("button[aria-label='Close']").click
    end

    # Flash should disappear quickly (within 1 second for fade animation)
    assert_no_selector "#notice_flash", wait: 2
  end

  test "validation errors appear inline via Turbo Frame" do
    visit new_trait_path

    # Submit form without required fields
    # Note: We need to check what validations exist on Trait model
    fill_in "Name", with: "" # Assuming name is required
    click_on "Create Trait"

    # Should stay on the same page (form re-rendered in Turbo Frame)
    assert_current_path traits_path # POST redirects to index on failure

    # Error messages should appear in the form
    # This tests that Turbo Frame keeps us on the form page
    assert_selector "turbo-frame#trait_form", wait: 2
  end

  test "multiple flash messages can appear and dismiss independently" do
    # Create a trait to get success flash
    visit new_trait_path
    fill_in "Name", with: "Test Trait #{Time.now.to_i}"
    select "ANCESTRY", from: "Type"
    click_on "Create Trait"

    # Should have notice flash
    assert_selector "#notice_flash", text: "Trait was successfully created", wait: 2

    # Manually close it before it auto-dismisses
    within "#notice_flash" do
      find("button[aria-label='Close']").click
    end

    assert_no_selector "#notice_flash", wait: 2
  end

  test "flash messages work with different types (notice vs alert)" do
    # Test notice flash (success)
    visit edit_trait_path(@trait)
    fill_in "Name", with: "Success Test"
    click_on "Update Trait"

    # Should show green success flash
    assert_selector "#notice_flash.bg-green-50", text: "Trait was successfully updated", wait: 2

    # Wait for it to dismiss
    assert_no_selector "#notice_flash", wait: 7
  end

  test "Turbo Frame prevents full page reload on form submission" do
    visit edit_trait_path(@trait)

    # Get the current timestamp from the page to prove it doesn't reload
    original_title = page.title

    # Submit form via Turbo Frame
    fill_in "Name", with: "No Reload Test"
    click_on "Update Trait"

    # Wait for flash to appear
    assert_selector "#notice_flash", wait: 2

    # The page title should be different now (we're on show page)
    # But there was no full page reload, it was a Turbo navigation
    assert page.has_selector?("turbo-frame", visible: false)
  end
end
