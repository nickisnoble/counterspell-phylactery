class AuthenticationMailer < ApplicationMailer
  def one_time_code(email, code)
    @email, @code = email, code
    mail(to: email, subject: "Portal wish granted") do |format|
      format.html { render AuthenticationMailer::OneTimeCode.new(code: code) }
      format.text { render AuthenticationMailer::OneTimeCodeText.new(code: code) }
    end
  end
end
