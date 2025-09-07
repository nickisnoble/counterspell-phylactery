class AuthenticationMailer < ApplicationMailer
  def one_time_code(email, code)
    @email, @code = email, code
    mail(to: email, subject: "Portal wish granted")
  end
end
