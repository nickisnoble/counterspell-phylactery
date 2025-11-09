require "test_helper"

class TurboFrameContentTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(email: "admin-frame@example.com", system_role: "admin", display_name: "Admin")
    post session_path, params: { email: @admin.email }
    code = @admin.reload.auth_code
    post validate_session_path, params: { code: code }
  end

  test "hero validation error response contains ONLY the turbo frame, not full page" do
    post heroes_path, params: {
      hero: { name: "Test", pronouns: "They/Them", role: "player" }
    }, headers: {
      "Turbo-Frame" => "hero_form"
    }

    assert_response :unprocessable_content

    # The response should contain turbo-frame but NOT the full page structure
    assert_select "turbo-frame#hero_form", count: 1

    # Should NOT have multiple h1 tags (would indicate full page render)
    h1_count = css_select("h1").count
    assert h1_count <= 1, "Expected 0-1 h1 tags, got #{h1_count}. Full page was rendered instead of just the frame."

    # Debug: Print response body to see what's being returned
    puts "\n=== Hero Validation Error Response ===" if ENV["DEBUG"]
    puts response.body[0..500] if ENV["DEBUG"]
    puts "======================================\n" if ENV["DEBUG"]
  end

  test "trait validation error response structure" do
    post traits_path, params: {
      trait: { name: "" }
    }, headers: {
      "Turbo-Frame" => "trait_form"
    }

    assert_response :unprocessable_content

    # Should have the frame
    assert_select "turbo-frame#trait_form", count: 1

    # Check if full page elements are present (they shouldn't be)
    full_page_elements = css_select("main, nav, header.flex").count
    assert full_page_elements == 0, "Full page elements found in Turbo Frame response"
  end

  test "page validation error contains only frame content" do
    post pages_path, params: {
      page: { title: "" }
    }, headers: {
      "Turbo-Frame" => "page_form"
    }

    assert_response :unprocessable_content

    # Verify it's just the frame
    assert_select "turbo-frame#page_form", count: 1

    # Check that form is present inside frame
    assert_select "turbo-frame#page_form form", count: 1

    # Debug output
    if ENV["DEBUG"]
      puts "\n=== Page Validation Response ==="
      puts response.body[0..500]
      puts "================================\n"
    end
  end

  test "successful form submit redirects and breaks out of frame" do
    trait = traits(:one)

    patch trait_path(trait), params: {
      trait: { name: "Updated Name" }
    }, headers: {
      "Turbo-Frame" => "trait_form"
    }

    # Should redirect (breaks out of frame)
    assert_response :redirect

    # Flash should be set
    assert_equal "Trait was successfully updated.", flash[:notice]
  end
end
