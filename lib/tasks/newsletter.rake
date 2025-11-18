namespace :newsletter do
  desc "Sync all existing users with newsletter=true to Buttondown"
  task sync: :environment do
    unless ENV["BUTTONDOWN_API_KEY"].present?
      puts "BUTTONDOWN_API_KEY environment variable is not set. Skipping sync."
      exit
    end

    service = ButtondownService.new
    users = User.where(newsletter: true)
    total = users.count
    success_count = 0
    error_count = 0

    puts "Syncing #{total} users to Buttondown..."

    users.find_each.with_index do |user, index|
      begin
        if service.subscribe(user.email)
          success_count += 1
          print "."
        else
          error_count += 1
          print "E"
        end
      rescue => e
        error_count += 1
        puts "\nError syncing #{user.email}: #{e.message}"
        print "E"
      end

      # Print progress every 50 users
      if (index + 1) % 50 == 0
        puts " #{index + 1}/#{total}"
      end
    end

    puts "\n\nSync complete!"
    puts "Successfully synced: #{success_count}"
    puts "Errors: #{error_count}"
  end
end
