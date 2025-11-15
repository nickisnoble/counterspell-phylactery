require "test_helper"

class DisposableEmailDomainListUpdateJobTest < ActiveJob::TestCase
  test "job is enqueued" do
    assert_enqueued_with(job: DisposableEmailDomainListUpdateJob) do
      DisposableEmailDomainListUpdateJob.perform_later
    end
  end

  test "job performs without error" do
    # Just verify the job can run - it calls the gem's updater
    assert_nothing_raised do
      DisposableEmailDomainListUpdateJob.new.perform
    end
  end
end
