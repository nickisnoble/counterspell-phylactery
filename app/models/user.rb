class User < ApplicationRecord
  include Sluggable

  has_many :sessions, dependent: :destroy
  before_create :generate_otp_secret

  validates :email,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP },
    nondisposable: true

  normalizes :email, with: ->(e) { e.strip.downcase }
  encrypts :otp_secret

  def auth_code
    totp.now
  end

  def self.authenticate_by(email:, code:)
    user = find_by(email: email)
    user if user&.has_valid_totp?(code)
  end

  def has_valid_totp?(code)
    totp.verify(code, drift_behind: 60 * 5).present?
  end

  private

    def generate_otp_secret
      self.otp_secret = ROTP::Base32.random(16)
    end

    def totp
      ROTP::TOTP.new(otp_secret, issuer: "Counterspell")
    end
end
