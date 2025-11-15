class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :admin_present?, :gm_or_admin?

  private

  def require_admin!
    redirect_to root_path, alert: "Admin access required" unless admin_present?
  end

  def require_gm_or_admin!
    redirect_to root_path, alert: "GM or Admin access required" unless gm_or_admin?
  end

  def admin_present?
    authenticated? && Current.user.admin?
  end

  def gm_or_admin?
    authenticated? && (Current.user.gm? || Current.user.admin?)
  end
end
