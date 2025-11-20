class SeatPurchaseForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :game_id, :integer
  attribute :user_id, :integer
  attribute :hero_id, :integer
  attribute :role, :string

  validates :game_id, :user_id, presence: true
  validates :hero_id, :role, presence: true
  validate :role_matches_hero
  validate :role_not_full
  validate :hero_available
  validate :one_association_per_event

  def initialize(attributes = {})
    super
    @game = Game.find_by(id: game_id) if game_id
    @user = User.find_by(id: user_id) if user_id
    @hero = Hero.find_by(id: hero_id) if hero_id
  end

  def game
    @game ||= Game.find_by(id: game_id)
  end

  def user
    @user ||= User.find_by(id: user_id)
  end

  def hero
    @hero ||= Hero.find_by(id: hero_id)
  end

  def available_heroes_for_role(role_name)
    return Hero.none unless game

    taken_hero_ids = game.seats.where.not(hero_id: nil).pluck(:hero_id)
    Hero.where(role: role_name)
        .where.not(id: taken_hero_ids)
        .order(:name)
  end

  def role_availability
    return {} unless game

    game.seats
        .joins(:hero)
        .where.not(hero_id: nil)
        .group("heroes.role")
        .count
  end

  def role_available?(role_name)
    role_availability.fetch(role_name, 0) < 2
  end

  def save
    return false unless valid?

    seat = game.seats.build(
      user: user,
      hero: hero
    )

    seat.save
  end

  private

  def role_matches_hero
    return unless hero && role

    unless hero.role == role
      errors.add(:hero, "must match selected role")
    end
  end

  def role_not_full
    return unless game && role

    count = role_availability.fetch(role, 0)
    if count >= 2
      errors.add(:role, "#{role.humanize} is full (2/2 players)")
    end
  end

  def hero_available
    return unless game && hero

    if game.seats.where(hero_id: hero.id).exists?
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
    ).exists?

    # Check if user is GMing any game at this event
    is_gm_at_event = Game.where(event: event, gm: user).exists?

    if existing_seat || is_gm_at_event
      errors.add(:user, "can only have one association per event")
    end
  end
end
