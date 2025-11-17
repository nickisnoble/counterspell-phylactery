class NewsletterMailer < ApplicationMailer
  def newsletter(user:, newsletter:)
    @user = user
    @newsletter = newsletter

    mail(
      to: user.email,
      subject: newsletter.subject
    )
  end
end
