require "test_helper"

class Dashboard::BroadcastsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    @admin = User.create!(email: "admin@test.com", system_role: "admin", display_name: "Admin")
    sign_in_as(@admin)
    @broadcast = Broadcast.create!(
      subject: "Test Broadcast",
      scheduled_at: 1.hour.from_now,
      recipient_type: "all_subscribers"
    )
  end

  test "index shows broadcasts" do
    get dashboard_broadcasts_url
    assert_response :success
  end

  test "new shows form" do
    get new_dashboard_broadcast_url
    assert_response :success
  end

  test "create creates broadcast" do
    assert_difference("Broadcast.count") do
      post dashboard_broadcasts_url, params: {
        broadcast: {
          subject: "New Broadcast",
          scheduled_at: 1.day.from_now,
          recipient_type: "all_subscribers",
          draft: true
        }
      }
    end
    assert_redirected_to dashboard_broadcasts_path
  end

  test "preview sends test email to current user" do
    assert_enqueued_emails 1 do
      post preview_dashboard_broadcast_url(@broadcast)
    end
    assert_redirected_to dashboard_broadcasts_path
  end

  test "update modifies broadcast" do
    patch dashboard_broadcast_url(@broadcast), params: {
      broadcast: { subject: "Updated Subject" }
    }
    assert_redirected_to dashboard_broadcasts_path
    assert_equal "Updated Subject", @broadcast.reload.subject
  end

  test "destroy deletes broadcast if not sent" do
    assert_difference("Broadcast.count", -1) do
      delete dashboard_broadcast_url(@broadcast)
    end
    assert_redirected_to dashboard_broadcasts_path
  end

  test "destroy prevents deletion if sent" do
    @broadcast.mark_as_sent!
    assert_no_difference("Broadcast.count") do
      delete dashboard_broadcast_url(@broadcast)
    end
    assert_redirected_to dashboard_broadcasts_path
  end

  private

  def sign_in_as(user)
    post session_url, params: { email: user.email, code: user.auth_code }
  end
end
