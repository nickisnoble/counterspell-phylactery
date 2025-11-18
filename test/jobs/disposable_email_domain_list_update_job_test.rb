require "test_helper"
require "webmock/minitest"

class DisposableEmailDomainListUpdateJobTest < ActiveJob::TestCase
  test "job is enqueued" do
    assert_enqueued_with(job: DisposableEmailDomainListUpdateJob) do
      DisposableEmailDomainListUpdateJob.perform_later
    end
  end

  test "job performs without error" do
    # Stub the external HTTP request for the disposable email list
    stub_request(:get, "https://raw.githubusercontent.com/disposable-email-domains/disposable-email-domains/master/disposable_email_blocklist.conf")
      .to_return(status: 200, body: "tempmail.com\nfakemail.com", headers: {})

    # Just verify the job can run - it calls the gem's updater
    assert_nothing_raised do
      DisposableEmailDomainListUpdateJob.new.perform
    end
  end
end
