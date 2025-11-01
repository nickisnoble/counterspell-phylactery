class SessionsController < ApplicationController
  include ActiveHashcash
  before_action :check_hashcash, only: :create

  rate_limit to: 3,
             within: 5.minutes,
             only: :create,
             with: -> { redirect_to new_session_url, alert: "Try again later." }

  allow_unauthenticated_access only: %i[ new create verify validate ]


  def new
    if authenticated?
      if !Current.user.display_name.present?
        redirect_to edit_user_path(Current.user)
      else
        redirect_to events_path
      end
    else
      render Sessions::New.new
    end
  end

  def create
    @user = User.find_or_initialize_by(email: params.require(:email))

    if @user.new_record? && !@user.save
      render Sessions::New.new, status: :unprocessable_content, alert: @user.errors.full_messages.to_sentence
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
    render Sessions::Verify.new(awaiting_login: session[:awaiting_login])
  end

  def validate
    email = session[:awaiting_login]
    code = params.require(:code)

    if user = User.authenticate_by(email:, code:)
      user.verify!
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

    def hashcash_after_failure
      redirect_back_or_to new_session_path, alert: "You might be a bot."
    end
end
