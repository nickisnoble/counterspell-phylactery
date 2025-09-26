class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create verify validate ]
  rate_limit to: 5, within: 3.minutes, only: %i[create validate], with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
    if authenticated?
      if !Current.user.display_name
        redirect_to edit_user_path(Current.user)
      else
        redirect_to root_path
      end
    end
  end

  def create
    @user = User.find_or_initialize_by(email: params.require(:email))

    if @user.new_record? && !@user.save
      render :new, status: :unprocessable_content, alert: @user.errors.full_messages.to_sentence
      return
    end

    email = @user.email
    code = @user.auth_code

    session[:awaiting_login] = email

    mailer = AuthenticationMailer.one_time_code(email, code)
    Rails.env.test? ? mailer.deliver_now : mailer.deliver_later

    redirect_to verify_session_path
  end

  def verify
  end

  def validate
    email = session[:awaiting_login]
    code = params.require(:code)

    if user = User.authenticate_by(email:, code:)
      start_new_session_for user
      session.delete(:awaiting_login)

      redirect_to root_path
    else
      redirect_to new_session_path, status: :unauthorized, error: "Dissonant weave. Try requesting new runes!"
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end


  private

    def redirect_if_authenticated
      redirect_to root_path if authenticated?
    end
end
