namespace :newsletter do
  desc "Sync all existing users with newsletter=true to Buttondown (DRY_RUN=true to preview, ASYNC=true to use background jobs)"
  task sync: :environment do
    unless ENV["BUTTONDOWN_API_KEY"].present?
      puts "⚠️  BUTTONDOWN_API_KEY environment variable is not set. Skipping sync."
      exit
    end

    dry_run = ENV["DRY_RUN"] == "true"
    async = ENV["ASYNC"] == "true"

    users = User.where(newsletter: true)
    total = users.count

    if dry_run
      puts "🔍 DRY RUN MODE - No actual changes will be made"
      puts "=" * 60
    end

    puts "📊 Found #{total} users subscribed to the newsletter"

    if total == 0
      puts "✅ Nothing to sync!"
      exit
    end

    puts "\n#{dry_run ? '📋 Would sync' : '🚀 Syncing'} the following users:"
    users.limit(5).each do |user|
      puts "  • #{user.email}"
    end

    if total > 5
      puts "  ... and #{total - 5} more"
    end

    unless dry_run
      print "\n⏳ Continue? (y/N): "
      response = STDIN.gets.chomp
      unless response.downcase == 'y'
        puts "❌ Sync cancelled"
        exit
      end
    end

    if dry_run
      puts "\n✅ Dry run complete! Run without DRY_RUN=true to actually sync."
      exit
    end

    if async
      puts "\n🔄 Queueing #{total} background jobs..."
      users.find_each do |user|
        NewsletterSyncJob.perform_later(user.id, true)
        print "."
      end
      puts "\n\n✅ #{total} jobs queued! Check your job queue for progress."
    else
      puts "\n🔄 Syncing #{total} users synchronously..."
      service = ButtondownService.new
      success_count = 0
      error_count = 0
      errors = []

      users.find_each.with_index do |user, index|
        begin
          if service.subscribe(user.email)
            success_count += 1
            print "."
          else
            error_count += 1
            errors << { email: user.email, error: "Subscribe returned false" }
            print "E"
          end
        rescue => e
          error_count += 1
          errors << { email: user.email, error: e.message }
          print "E"
        end

        # Print progress every 50 users
        if (index + 1) % 50 == 0
          puts " #{index + 1}/#{total}"
        end
      end

      puts "\n\n" + "=" * 60
      puts "✅ Sync complete!"
      puts "=" * 60
      puts "Successfully synced: #{success_count}"
      puts "Errors: #{error_count}"

      if errors.any?
        puts "\n❌ Failed emails:"
        errors.first(10).each do |err|
          puts "  • #{err[:email]}: #{err[:error]}"
        end

        if errors.size > 10
          puts "  ... and #{errors.size - 10} more errors"
        end
      end
    end
  end
end
