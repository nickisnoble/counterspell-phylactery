require "test_helper"

class TurboSuccessRedirectTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(email: "redirect@example.com", system_role: "admin", display_name: "Redirect Admin")
    post session_path, params: { email: @admin.email }
    code = @admin.reload.auth_code
    post validate_session_path, params: { code: code }
    @trait = traits(:one)
  end

  test "successful form submission WITH Turbo-Frame header redirects correctly" do
    patch trait_path(@trait), params: {
      trait: { name: "Updated Name" }
    }, headers: {
      "Turbo-Frame" => ActionView::RecordIdentifier.dom_id(@trait)
    }

    puts "\n" + "="*80
    puts "SUCCESSFUL TURBO FRAME SUBMISSION:"
    puts "="*80
    puts "Status: #{response.status}"
    puts "Location header: #{response.headers['Location']}"
    puts "Response body (first 500 chars):"
    puts response.body[0..500]
    puts "="*80

    assert_response :redirect
    follow_redirect!

    puts "\n" + "="*80
    puts "AFTER REDIRECT:"
    puts "="*80
    puts "Status: #{response.status}"
    puts "Response body (first 500 chars):"
    puts response.body[0..500]
    puts "Contains turbo-frame? #{response.body.include?('<turbo-frame')}"
    puts "Contains full page? #{response.body.include?('<!doctype')}"
    puts "="*80
  end
end
