require "test_helper"

class TurboFrameRenderingTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(email: "debug@example.com", system_role: "admin", display_name: "Debug Admin")
    post session_path, params: { email: @admin.email }
    code = @admin.reload.auth_code
    post validate_session_path, params: { code: code }
  end

  test "form validation error WITH Turbo-Frame header returns ONLY frame content" do
    post traits_path, params: {
      trait: { name: "", type: "" } # Invalid
    }, headers: {
      "Turbo-Frame" => "new_trait"
    }

    puts "\n" + "="*80
    puts "TURBO FRAME REQUEST - RESPONSE BODY:"
    puts "="*80
    puts response.body[0..1000]
    puts "="*80
    puts "Response starts with <!DOCTYPE? #{response.body.start_with?('<!DOCTYPE')}"
    puts "Response contains <turbo-frame? #{response.body.include?('<turbo-frame')}"
    puts "Response contains <html>? #{response.body.include?('<html>')}"
    puts "="*80

    assert_response :unprocessable_content

    # CRITICAL: Should NOT have full page HTML
    refute response.body.include?('<!DOCTYPE'), "Should NOT return full DOCTYPE when Turbo Frame request"
    refute response.body.include?('<html>'), "Should NOT return full HTML page when Turbo Frame request"

    # CRITICAL: Should ONLY have turbo-frame tag
    assert response.body.include?('<turbo-frame'), "MUST return turbo-frame tag"
    assert response.body.include?('id="new_trait"'), "MUST have correct frame ID"
  end

  test "form validation error WITHOUT Turbo-Frame header returns full page" do
    post traits_path, params: {
      trait: { name: "", type: "" } # Invalid
    }

    puts "\n" + "="*80
    puts "NORMAL REQUEST - RESPONSE BODY:"
    puts "="*80
    puts response.body[0..1000]
    puts "="*80
    puts "Response starts with <!DOCTYPE? #{response.body.start_with?('<!DOCTYPE')}"
    puts "="*80

    assert_response :unprocessable_content

    # Should have full page HTML
    assert response.body.downcase.include?('<!doctype'), "Should return full page for normal request"
  end
end
