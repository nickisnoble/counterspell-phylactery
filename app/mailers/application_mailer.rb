class ApplicationMailer < ActionMailer::Base
  default from: "counterspell@scrolls.counterspell.games",
          reply_to: "nick@counterspell.games"
  layout "mailer"
end
