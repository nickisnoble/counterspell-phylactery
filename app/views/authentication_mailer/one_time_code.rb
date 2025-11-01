class AuthenticationMailer::OneTimeCode < ApplicationComponent
  def initialize(code:)
    @code = code
  end

  def view_template
    doctype

    html do
      head do
        meta content: "text/html; charset=UTF-8", "http-equiv": "Content-Type"
      end

      body do
        h1 { "The doortal awaits! Your runes:" }
        p(style: "font-family: monospace; font-size: 2rem; font-weight: bold") { @code }
        p(style: "font-style: italic") { "They must be cast within 5 minutes, or it will return to the rift!" }
        br
        br
        p do
          plain "If you need a new set of runes, "
          a(href: new_session_url) { "log in" }
          plain " again."
        end
        p(style: "opacity: 0.5") { "(If you did not request this, you can safely ignore this email.)" }
      end
    end
  end
end
