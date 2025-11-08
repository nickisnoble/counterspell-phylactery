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
end
