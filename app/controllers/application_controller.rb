class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  layout -> { Views::Layouts::ApplicationLayout }

  private

  def require_admin!
    redirect_to root_path unless admin_present?
  end

  def admin_present?
    authenticated? && Current.user.admin?
  end

  # Detect if this is a Turbo Frame request
  # Turbo Frame requests include a "Turbo-Frame" header with the frame ID
  def turbo_frame_request?
    request.headers["Turbo-Frame"].present?
  end

  # Render flash messages as a Turbo Stream response
  # Use this when responding to Turbo Frame/Stream requests
  def render_turbo_stream_flash_now
    render turbo_stream: turbo_stream.update("flash-messages",
      Views::Shared::FlashTurboStream.new.call
    )
  end
end
