class Seat < ApplicationRecord
  belongs_to :game
  belongs_to :user, optional: true
  belongs_to :hero, optional: true

  validate :hero_unique_per_game, if: :hero_id?
  validate :one_association_per_event, if: :user_id?
  validate :seat_capacity_not_exceeded, if: :user_id?

  before_create :set_purchased_at, if: :user_id?

  # Broadcast seat changes to event subscribers
  after_commit :broadcast_seat_update, on: [:create, :update]

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
    relevant_changes = previous_changes.slice("checked_in_at", "user_id", "hero_id", "game_id")
    return if relevant_changes.empty?

    # Seats only move between games within the same event, so broadcasting the current event is sufficient
    broadcast_refresh_to(game.event)
  end
end
