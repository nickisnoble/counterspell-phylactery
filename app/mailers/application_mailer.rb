class ApplicationMailer < ActionMailer::Base
  default from: "counterspell@scrolls.counterspell.games",
          reply_to: "nick@counterspell.games"
  layout "mailer"

  helper_method :add_utm_params

  private

  # Add UTM parameters to URLs for tracking in Pirsch
  def add_utm_params(url, content: nil)
    uri = URI.parse(url)
    params = URI.decode_www_form(uri.query || "")

    # Add UTM parameters
    params << ["utm_source", "email"]
    params << ["utm_medium", utm_medium]
    params << ["utm_campaign", utm_campaign]
    params << ["utm_content", content] if content.present?

    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

  # Override these in subclasses for specific UTM values
  def utm_medium
    "broadcast"
  end

  def utm_campaign
    "newsletter"
  end
end
