require "test_helper"

class NewsletterMailerTest < ActionMailer::TestCase
  setup do
    @user = User.create!(email: "test@example.com")
    @newsletter = Newsletter.create!(subject: "Test Newsletter", scheduled_at: 1.hour.from_now)
    @newsletter.body = "This is a test newsletter."
  end

  test "newsletter" do
    email = NewsletterMailer.newsletter(user: @user, newsletter: @newsletter)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email], email.to
    assert_equal "Test Newsletter", email.subject
    assert_match "This is a test newsletter", email.body.encoded
    assert_match "View in browser", email.body.encoded
    assert_match "Unsubscribe", email.body.encoded
  end
end
