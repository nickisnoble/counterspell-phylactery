require "test_helper"
require "base64"
require "openssl"

class ResendWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "test@example.com",
      display_name: "Test User",
      system_role: "player",
      newsletter: true,
      never_send_email: false
    )

    @webhook_secret = "whsec_#{Base64.strict_encode64("resend_test_secret")}"
    @decoded_webhook_secret = Base64.strict_decode64(@webhook_secret.delete_prefix("whsec_"))
    ENV["RESEND_WEBHOOK_SECRET"] = @webhook_secret
  end

  teardown do
    ENV.delete("RESEND_WEBHOOK_SECRET")
  end

  test "email.bounced sets never_send_email to true" do
    payload = {
      type: "email.bounced",
      created_at: "2024-11-22T23:41:12.126Z",
      data: {
        email_id: SecureRandom.uuid,
        from: "noreply@example.com",
        to: [@user.email],
        subject: "Test Email",
        bounce: {
          type: "Permanent",
          subType: "Suppressed",
          message: "Address is on the suppression list"
        },
        tags: {
          broadcast_id: "123"
        }
      }
    }

    assert_changes -> { @user.reload.never_send_email }, from: false, to: true do
      post_resend_webhook(payload)
    end

    assert_response :ok
    assert_equal 1, EmailEvent.where(user: @user, event_type: "email.bounced").count
  end

  test "email.complained sets never_send_email to true" do
    payload = {
      type: "email.complained",
      created_at: "2024-11-22T23:41:12.126Z",
      data: {
        email_id: SecureRandom.uuid,
        from: "noreply@example.com",
        to: [@user.email],
        subject: "Test Email",
        tags: {
          broadcast_id: "123"
        }
      }
    }

    assert_changes -> { @user.reload.never_send_email }, from: false, to: true do
      post_resend_webhook(payload)
    end

    assert_response :ok
    assert_equal 1, EmailEvent.where(user: @user, event_type: "email.complained").count
  end

  test "email.delivered tracks event without setting never_send_email" do
    payload = {
      type: "email.delivered",
      created_at: "2024-11-22T23:41:12.126Z",
      data: {
        email_id: SecureRandom.uuid,
        from: "noreply@example.com",
        to: [@user.email],
        subject: "Test Email",
        tags: {
          broadcast_id: "123"
        }
      }
    }

    assert_no_changes -> { @user.reload.never_send_email } do
      post_resend_webhook(payload)
    end

    assert_response :ok
    assert_equal 1, EmailEvent.where(user: @user, event_type: "email.delivered").count
  end

  test "email.failed tracks event" do
    payload = {
      type: "email.failed",
      created_at: "2024-11-22T23:41:12.126Z",
      data: {
        email_id: SecureRandom.uuid,
        from: "noreply@example.com",
        to: [@user.email],
        subject: "Test Email",
        failed: {
          reason: "Invalid recipient"
        },
        tags: {
          broadcast_id: "123"
        }
      }
    }

    post_resend_webhook(payload)

    assert_response :ok
    assert_equal 1, EmailEvent.where(user: @user, event_type: "email.failed").count
  end

  test "email.sent tracks event" do
    payload = {
      type: "email.sent",
      created_at: "2024-11-22T23:41:12.126Z",
      data: {
        email_id: SecureRandom.uuid,
        from: "noreply@example.com",
        to: [@user.email],
        subject: "Test Email",
        tags: {
          broadcast_id: "123"
        }
      }
    }

    post_resend_webhook(payload)

    assert_response :ok
    assert_equal 1, EmailEvent.where(user: @user, event_type: "email.sent").count
  end

  test "email.delivery_delayed tracks event" do
    payload = {
      type: "email.delivery_delayed",
      created_at: "2024-11-22T23:41:12.126Z",
      data: {
        email_id: SecureRandom.uuid,
        from: "noreply@example.com",
        to: [@user.email],
        subject: "Test Email",
        tags: {
          broadcast_id: "123"
        }
      }
    }

    post_resend_webhook(payload)

    assert_response :ok
    assert_equal 1, EmailEvent.where(user: @user, event_type: "email.delivery_delayed").count
  end

  test "email.opened tracks event" do
    payload = {
      type: "email.opened",
      created_at: "2024-11-22T23:41:12.126Z",
      data: {
        email_id: SecureRandom.uuid,
        from: "noreply@example.com",
        to: [@user.email],
        subject: "Test Email",
        tags: {
          broadcast_id: "123"
        }
      }
    }

    post_resend_webhook(payload)

    assert_response :ok
    assert_equal 1, EmailEvent.where(user: @user, event_type: "email.opened").count
  end

  test "email.clicked tracks event with click data" do
    payload = {
      type: "email.clicked",
      created_at: "2024-11-22T23:41:12.126Z",
      data: {
        email_id: SecureRandom.uuid,
        from: "noreply@example.com",
        to: [@user.email],
        subject: "Test Email",
        click: {
          ipAddress: "192.168.1.1",
          link: "https://example.com/link",
          timestamp: "2024-11-22T23:41:15.000Z",
          userAgent: "Mozilla/5.0"
        },
        tags: {
          broadcast_id: "123"
        }
      }
    }

    post_resend_webhook(payload)

    assert_response :ok
    event = EmailEvent.find_by(user: @user, event_type: "email.clicked")
    assert_not_nil event
    assert_equal "https://example.com/link", event.metadata["click"]["link"]
  end

  test "handles email to unknown user gracefully" do
    payload = {
      type: "email.delivered",
      created_at: "2024-11-22T23:41:12.126Z",
      data: {
        email_id: SecureRandom.uuid,
        from: "noreply@example.com",
        to: ["unknown@example.com"],
        subject: "Test Email",
        tags: {
          broadcast_id: "123"
        }
      }
    }

    post_resend_webhook(payload)

    assert_response :ok
    # Should not create an event since user doesn't exist
    assert_equal 0, EmailEvent.count
  end

  test "handles multiple recipients" do
    user2 = User.create!(
      email: "test2@example.com",
      display_name: "Test User 2",
      system_role: "player",
      newsletter: true
    )

    payload = {
      type: "email.delivered",
      created_at: "2024-11-22T23:41:12.126Z",
      data: {
        email_id: SecureRandom.uuid,
        from: "noreply@example.com",
        to: [@user.email, user2.email],
        subject: "Test Email",
        tags: {
          broadcast_id: "123"
        }
      }
    }

    post_resend_webhook(payload)

    assert_response :ok
    assert_equal 2, EmailEvent.where(event_type: "email.delivered").count
  end

  test "returns 200 OK for all events" do
    payload = {
      type: "email.sent",
      created_at: "2024-11-22T23:41:12.126Z",
      data: {
        email_id: SecureRandom.uuid,
        from: "noreply@example.com",
        to: [@user.email],
        subject: "Test Email"
      }
    }

    post_resend_webhook(payload)
    assert_response :ok
  end

  test "returns unauthorized when signature validation fails" do
    payload = {
      type: "email.sent",
      created_at: "2024-11-22T23:41:12.126Z",
      data: {
        email_id: SecureRandom.uuid,
        from: "noreply@example.com",
        to: [@user.email],
        subject: "Test Email"
      }
    }

    headers = signed_headers(payload)
    headers["SVIX-SIGNATURE"] = "v1,invalid"

    assert_no_changes -> { EmailEvent.count } do
      post_resend_webhook(payload, headers: headers)
    end

    assert_response :unauthorized
  end

  private

  def post_resend_webhook(payload, headers: signed_headers(payload))
    post resend_webhooks_path, params: payload, as: :json, headers: headers
  end

  def signed_headers(payload, svix_id: SecureRandom.uuid, timestamp: Time.now.to_i.to_s)
    payload_json = payload.to_json
    signed_content = "#{svix_id}.#{timestamp}.#{payload_json}"
    signature = Base64.strict_encode64(
      OpenSSL::HMAC.digest("sha256", @decoded_webhook_secret, signed_content)
    )

    {
      "SVIX-ID" => svix_id,
      "SVIX-TIMESTAMP" => timestamp,
      "SVIX-SIGNATURE" => "v1,#{signature}"
    }
  end
end
