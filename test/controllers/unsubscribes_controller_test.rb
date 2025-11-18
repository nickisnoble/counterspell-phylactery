require "test_helper"

class UnsubscribesControllerTest < ActionDispatch::IntegrationTest
  test "show displays unsubscribe page with valid token" do
    user = User.create!(email: "test@example.com", newsletter: true)
    get unsubscribe_path(token: user.unsubscribe_token)
    assert_response :success
  end

  test "show redirects with invalid token" do
    get unsubscribe_path(token: "invalid")
    assert_redirected_to root_path
  end

  test "create unsubscribes user and records event" do
    user = User.create!(email: "test@example.com", newsletter: true)

    assert_difference "UnsubscribeEvent.count", 1 do
      post unsubscribe_path(token: user.unsubscribe_token), params: { reason: "too_many_emails" }
    end

    assert_not user.reload.newsletter?
    assert_equal "too_many_emails", user.unsubscribe_events.last.reason
    assert_redirected_to unsubscribe_path(token: user.unsubscribe_token)
  end

  test "create works without reason" do
    user = User.create!(email: "test@example.com", newsletter: true)

    assert_difference "UnsubscribeEvent.count", 1 do
      post unsubscribe_path(token: user.unsubscribe_token)
    end

    assert_not user.reload.newsletter?
    assert_nil user.unsubscribe_events.last.reason
  end

  test "create redirects with invalid token" do
    assert_no_difference "UnsubscribeEvent.count" do
      post unsubscribe_path(token: "invalid"), params: { reason: "too_many_emails" }
    end

    assert_redirected_to root_path
  end
end
