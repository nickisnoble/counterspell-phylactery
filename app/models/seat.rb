class Seat < ApplicationRecord
  belongs_to :game
  belongs_to :user, optional: true
  belongs_to :hero, optional: true
  has_many :broadcasts, as: :broadcastable, dependent: :destroy

  validate :hero_unique_per_game, if: :hero_id?
  validate :one_association_per_event, if: :user_id?
  validate :seat_capacity_not_exceeded, if: :user_id?

  before_create :set_purchased_at, if: :user_id?

  # Broadcast seat changes to event subscribers
  after_commit :broadcast_seat_update, on: [:create, :update]
  after_commit :send_confirmation_email, on: :create, if: :user_id?

  def checked_in?
    checked_in_at.present?
  end

  def check_in!
    update!(checked_in_at: Time.current)
  end

  def qr_code_url
    # Generate URL that uniquely identifies this seat for check-in
    host = Rails.application.config.action_mailer.default_url_options[:host]
    port = Rails.application.config.action_mailer.default_url_options[:port]

    url_options = { token: qr_token }
    url_options[:host] = host if host
    url_options[:port] = port if port && port != 80 && port != 443

    Rails.application.routes.url_helpers.checkin_url(**url_options)
  end

  def qr_token
    # Generate a secure token for this seat
    # Using a hash of seat id + secret to prevent guessing
    Digest::SHA256.hexdigest("#{id}-#{Rails.application.secret_key_base}")[0...32]
  end

  def qr_code_svg
    # Generate QR code as SVG for embedding in emails
    require 'rqrcode'
    qrcode = RQRCode::QRCode.new(qr_code_url)
    qrcode.as_svg(
      module_size: 4,
      standalone: true,
      use_path: true
    )
  end

  private

  def hero_unique_per_game
    return unless game

    if game.seats.where(hero_id: hero_id).where.not(id: id).exists?
      errors.add(:hero, "is already taken at this table")
    end
  end

  def one_association_per_event
    return unless game && user

    event = game.event

    # Check if user has another seat at this event
    existing_seat = Seat.joins(:game).where(
      user: user,
      games: { event_id: event.id }
    ).where.not(id: id).exists?

    # Check if user is GMing any game at this event
    is_gm_at_event = Game.where(event: event, gm: user).exists?

    if existing_seat || is_gm_at_event
      errors.add(:user, "can only have one association per event")
    end
  end

  def seat_capacity_not_exceeded
    return unless game && user_id

    seats_taken = game.seats.where.not(id: id).where.not(user_id: nil).count
    if seats_taken >= game.seat_count
      errors.add(:base, "This table is full")
    end
  end

  def set_purchased_at
    self.purchased_at ||= Time.current
  end

  def broadcast_seat_update
    return unless game&.event && user_id

    # Only broadcast on meaningful changes
    return unless saved_change_to_checked_in_at? || saved_change_to_user_id? || saved_change_to_hero_id?

    # Broadcast a refresh to anyone viewing this event
    broadcast_refresh_to(game.event)
  end

  def send_confirmation_email
    # Create a broadcast for this seat confirmation (will be sent immediately)
    broadcast = broadcasts.create!(
      subject: "Seat Confirmation",
      scheduled_at: Time.current,
      draft: false,
      recipient_type: "single_recipient",
      sent_at: Time.current  # Mark as sent immediately to prevent BroadcastJob from picking it up
    )
    broadcast.body = "Your seat has been confirmed!"

    # Send the email immediately
    BroadcastMailer.broadcast(user: user, broadcast: broadcast).deliver_later
  end
end
