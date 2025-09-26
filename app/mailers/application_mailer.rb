class ApplicationMailer < ActionMailer::Base
  default from: "noreply@scrolls.counterspell.games",
          reply_to: "nick@counterspell.games"
  layout "mailer"
end
