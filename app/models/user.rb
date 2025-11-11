class User < ApplicationRecord
  include Sluggable

  has_many :sessions, dependent: :destroy
  has_rich_text :bio

  before_create :generate_otp_secret
  encrypts :otp_secret

  normalizes :email, with: ->(e) { e.strip.downcase }
  validates :email,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP },
    nondisposable: true

  normalizes :display_name, with: ->(e) { e.strip }
  validates :display_name, length: { maximum: 40 }

  enum :system_role, %w[ player gm staff admin ].index_by(&:itself), default: :player, validate: true

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

  def verify!
    update!(verified: true)
  end

  private

    def generate_otp_secret
      self.otp_secret = ROTP::Base32.random(16)
    end

    def totp
      ROTP::TOTP.new(otp_secret, issuer: "Counterspell")
    end
end
