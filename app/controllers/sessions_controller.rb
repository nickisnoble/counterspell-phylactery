class SessionsController < ApplicationController
  include ActiveHashcash
  before_action :check_hashcash, only: :create, unless: -> { Rails.env.test? }

  rate_limit to: 3,
             within: 5.minutes,
             only: :create,
             with: -> { redirect_to new_session_url, alert: "Try again later." }

  allow_unauthenticated_access only: %i[ new create verify validate ]


  def new
    if authenticated?
      redirect_to events_path
    else
      render Views::Sessions::New.new
    end
  end

  def create
    @user = User.find_or_initialize_by(email: params.require(:email))

    if @user.new_record? && !@user.save
      render Views::Sessions::New.new, status: :unprocessable_content, alert: @user.errors.full_messages.to_sentence
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
    render Views::Sessions::Verify.new(email: session[:awaiting_login])
  end

  def validate
    email = session[:awaiting_login]

    unless email.present?
      redirect_to new_session_path, alert: "Session expired. Please try again."
      return
    end

    code = params.require(:code)

    if user = User.authenticate_by(email:, code:)
      user.verify!
      start_new_session_for user
      session.delete(:awaiting_login)

      # If user needs to complete profile, preserve the return_to URL
      if !user.display_name.present?
        redirect_to edit_user_path(user)
      else
        redirect_to after_authentication_url
      end
    else
      redirect_to new_session_path, status: :unauthorized, error: "Dissonant weave. Try requesting new runes!"
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end


  private

    def hashcash_after_failure
      redirect_back_or_to new_session_path, alert: "You might be a bot."
    end
end
