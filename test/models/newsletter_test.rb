require "test_helper"

class NewsletterTest < ActiveSupport::TestCase
  test "requires subject" do
    newsletter = Newsletter.new(scheduled_at: 1.day.from_now)
    assert_not newsletter.valid?
    assert_includes newsletter.errors[:subject], "can't be blank"
  end

  test "requires scheduled_at" do
    newsletter = Newsletter.new(subject: "Test Newsletter")
    assert_not newsletter.valid?
    assert_includes newsletter.errors[:scheduled_at], "can't be blank"
  end

  test "has rich text body" do
    newsletter = Newsletter.create!(subject: "Test", scheduled_at: 1.day.from_now)
    assert_respond_to newsletter, :body
    assert newsletter.body.is_a?(ActionText::RichText) || newsletter.body.nil?
  end

  test "defaults to draft" do
    newsletter = Newsletter.create!(subject: "Test", scheduled_at: 1.day.from_now)
    assert newsletter.draft?
  end

  test "allows updating scheduled_at before sent" do
    newsletter = Newsletter.create!(subject: "Test", scheduled_at: 1.day.from_now)
    newsletter.scheduled_at = 2.days.from_now
    assert newsletter.valid?
  end

  test "prevents updating scheduled_at after sent" do
    newsletter = Newsletter.create!(subject: "Test", scheduled_at: 1.day.ago, sent_at: 1.hour.ago)
    newsletter.scheduled_at = 2.days.from_now
    assert_not newsletter.valid?
    assert_includes newsletter.errors[:scheduled_at], "cannot be changed after newsletter is sent"
  end

  test "prevents updating sent_at after sent" do
    newsletter = Newsletter.create!(subject: "Test", scheduled_at: 1.day.ago, sent_at: 1.hour.ago)
    newsletter.sent_at = 2.hours.ago
    assert_not newsletter.valid?
    assert_includes newsletter.errors[:sent_at], "cannot be changed after newsletter is sent"
  end

  test "allows updating body after sent" do
    newsletter = Newsletter.create!(subject: "Test", scheduled_at: 1.day.ago, sent_at: 1.hour.ago)
    newsletter.body = "Updated content"
    assert newsletter.valid?
  end

  test "sent? returns true when sent_at is present" do
    newsletter = Newsletter.create!(subject: "Test", scheduled_at: 1.day.ago, sent_at: 1.hour.ago)
    assert newsletter.sent?
  end

  test "sent? returns false when sent_at is nil" do
    newsletter = Newsletter.create!(subject: "Test", scheduled_at: 1.day.from_now)
    assert_not newsletter.sent?
  end

  test "mark_as_sent! sets sent_at" do
    newsletter = Newsletter.create!(subject: "Test", scheduled_at: 1.day.from_now)
    assert_nil newsletter.sent_at
    newsletter.mark_as_sent!
    assert_not_nil newsletter.sent_at
  end

  test "published scope excludes drafts" do
    Newsletter.create!(subject: "Draft", scheduled_at: 1.day.from_now, draft: true)
    published = Newsletter.create!(subject: "Published", scheduled_at: 1.day.from_now, draft: false)
    assert_equal [published], Newsletter.published.to_a
  end

  test "can unpublish after sending" do
    newsletter = Newsletter.create!(subject: "Test", scheduled_at: 1.day.ago, sent_at: 1.hour.ago, draft: false)
    newsletter.draft = true
    assert newsletter.valid?
  end
end
