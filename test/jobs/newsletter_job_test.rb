require "test_helper"

class NewsletterJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "sends pending newsletters" do
    user = User.create!(email: "test@example.com", newsletter: true)
    newsletter = Newsletter.create!(
      subject: "Test Newsletter",
      scheduled_at: 1.hour.ago,
      draft: false
    )

    assert_enqueued_emails 1 do
      NewsletterJob.perform_now
    end

    assert newsletter.reload.sent?
  end

  test "does not send draft newsletters" do
    user = User.create!(email: "test@example.com", newsletter: true)
    newsletter = Newsletter.create!(
      subject: "Draft Newsletter",
      scheduled_at: 1.hour.ago,
      draft: true
    )

    assert_no_enqueued_emails do
      NewsletterJob.perform_now
    end

    assert_not newsletter.reload.sent?
  end

  test "does not send future newsletters" do
    user = User.create!(email: "test@example.com", newsletter: true)
    newsletter = Newsletter.create!(
      subject: "Future Newsletter",
      scheduled_at: 1.hour.from_now,
      draft: false
    )

    assert_no_enqueued_emails do
      NewsletterJob.perform_now
    end

    assert_not newsletter.reload.sent?
  end

  test "only sends to users with newsletter preference enabled" do
    subscribed_user = User.create!(email: "subscribed@example.com", newsletter: true)
    unsubscribed_user = User.create!(email: "unsubscribed@example.com", newsletter: false)

    newsletter = Newsletter.create!(
      subject: "Test Newsletter",
      scheduled_at: 1.hour.ago,
      draft: false
    )

    assert_enqueued_emails 1 do
      NewsletterJob.perform_now
    end
  end

  test "skips users flagged to never receive email" do
    deliverable_user = User.create!(email: "deliverable@example.com", newsletter: true, never_send_email: false)
    blocked_user = User.create!(email: "blocked@example.com", newsletter: true, never_send_email: true)

    newsletter = Newsletter.create!(
      subject: "Blocked Test Newsletter",
      scheduled_at: 1.hour.ago,
      draft: false
    )

    assert_enqueued_emails 1 do
      NewsletterJob.perform_now
    end
  end
end
