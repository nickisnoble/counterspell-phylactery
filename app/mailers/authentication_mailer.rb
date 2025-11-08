class AuthenticationMailer < ApplicationMailer
  def one_time_code(email, code)
    @email, @code = email, code
    mail(to: email, subject: "Portal wish granted") do |format|
      format.html { render Views::AuthenticationMailer::OneTimeCode.new(code: code) }
      format.text { render Views::AuthenticationMailer::OneTimeCodeText.new(code: code) }
    end
  end
end
