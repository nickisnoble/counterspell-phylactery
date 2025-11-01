class AuthenticationMailer::OneTimeCodeText < ApplicationComponent
  def initialize(code:)
    @code = code
  end

  def view_template
    whitespace
    plain "The doortal awaits! Your runes:"
    whitespace
    whitespace
    plain @code
    whitespace
    whitespace
    plain "They must be cast within 5 minutes, or it will return to the rift!"
    whitespace
    whitespace
    plain "—"
    whitespace
    whitespace
    plain "If you need a new set of runes, log in again:"
    whitespace
    plain new_session_url
    whitespace
    plain "(If you did not request this, you can safely ignore this email.)"
    whitespace
  end
end
