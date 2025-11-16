# frozen_string_literal: true

class Views::Games::Show < Views::Base
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::ButtonTo

  register_output_helper :turbo_stream_from

  def initialize(game:, event:, available_seats:, seats:, current_user:, is_today: false, is_gm_or_admin: false)
    @game = game
    @event = event
    @available_seats = available_seats
    @seats = seats
    @current_user = current_user
    @is_today = is_today
    @is_gm_or_admin = is_gm_or_admin
  end

  def view_template
    content_for(:title, "#{@event.name} - #{@game.gm.display_name}'s Table")

    # Subscribe to turbo streams for realtime updates
    turbo_stream_from(@event)

    main(class: "w-full max-w-3xl mx-auto px-4 py-12 bg-amber-50 min-h-screen") do
      # Back link
      div(class: "mb-8") do
        link_to("← Back to #{@event.name}", event_path(@event), class: "font-serif text-purple-900 hover:text-purple-700 font-medium transition")
      end

      # Game header
      div(class: "border border-black/10 rounded-sm bg-white/70 p-6 mb-8") do
        div(class: "mb-6 pb-4 border-b border-black/10") do
          div(class: "flex items-center gap-3 mb-2") do
            i(class: "fa-duotone fa-dice-d20 text-2xl text-purple-500")
            h1(class: "font-display text-4xl text-blue-900") { @game.gm.display_name }
          end
          p(class: "font-serif text-blue-900/60 text-sm") { "Game Master" }
        end

        div(class: "grid md:grid-cols-2 gap-6") do
          # Event info
          div do
            div(class: "text-sm font-serif font-medium text-blue-900/80 mb-2") { "Event" }
            div(class: "font-display text-lg text-purple-900") { @event.name }
            if @event.date
              div(class: "text-xs font-serif text-blue-900/60 mt-1") do
                @event.date.strftime('%A, %B %d, %Y')
              end
            end
          end

          # Seats info
          div do
            div(class: "text-sm font-serif font-medium text-blue-900/80 mb-2") { "Table Status" }
            div(class: "font-serif text-blue-900") do
              plain "#{@game.seat_count} #{'seat'.pluralize(@game.seat_count)} • "
              if @available_seats > 0
                span(class: "text-emerald-700 font-medium") { "#{@available_seats} available" }
              else
                span(class: "text-rose-700 font-medium") { "Full" }
              end
            end
          end
        end
      end

      # Seated players
      if @seats.any?
        div(class: "border border-black/10 rounded-sm bg-white/70 p-6") do
          h2(class: "font-display text-2xl text-blue-900 mb-6") { "Seated Players" }
          div(class: "space-y-4") do
            @seats.each do |seat|
              render_seat(seat)
            end
          end
        end
      else
        div(class: "border border-black/10 rounded-sm bg-white/70 p-8 text-center") do
          p(class: "font-serif text-blue-900/60") { "No players seated yet" }
        end
      end
    end
  end

  private

  def render_seat(seat)
    div(class: "border border-black/10 rounded-sm p-5 bg-amber-50/50") do
      div(class: "flex items-start justify-between gap-4") do
        # Player and Hero info
        div(class: "flex-1") do
          # Player details
          div(class: "mb-4") do
            div(class: "font-display text-xl text-blue-900 mb-1") { seat.user.display_name }
            if seat.user.pronouns.present?
              div(class: "text-sm font-serif text-blue-900/70") { seat.user.pronouns }
            end
            if seat.user.email.present?
              div(class: "text-sm font-serif text-blue-900/60 mt-1") { seat.user.email }
            end
          end

          # Hero details
          if seat.hero
            div(class: "mb-4 pb-4 border-t border-black/10 pt-4") do
              div(class: "flex items-center gap-2 mb-2") do
                i(class: "fa-solid fa-mask text-purple-500")
                div(class: "font-serif font-semibold text-blue-900") { seat.hero.name }
              end
              if seat.hero.pronouns.present?
                div(class: "text-sm font-serif text-blue-900/70 mb-1") { seat.hero.pronouns }
              end
              if seat.hero.role.present?
                div(class: "text-sm font-serif text-blue-900/70 capitalize") { "Role: #{seat.hero.role.humanize}" }
              end
            end
          end

          # User bio
          if seat.user.bio.present?
            div(class: "pt-4 border-t border-black/10") do
              div(class: "text-sm font-serif font-semibold text-blue-900/80 mb-2") { "Bio:" }
              div(class: "prose prose-sm max-w-none font-serif text-blue-900/70") do
                render seat.user.bio
              end
            end
          end
        end

        # Checkin button (only for today's games)
        if @is_today && can_check_in?(seat)
          render Views::Components::CheckinButton.new(seat: seat, variant: :card)
        elsif @is_today && seat.checked_in?
          div(class: "text-right") do
            div(class: "text-sm font-serif font-semibold text-emerald-700 flex items-center gap-1") do
              i(class: "fa-solid fa-check")
              plain "Checked in"
            end
            if seat.checked_in_at
              div(class: "text-xs font-serif text-blue-900/60 mt-1") { seat.checked_in_at.strftime("%I:%M %p") }
            end
          end
        end
      end
    end
  end

  def can_check_in?(seat)
    return true if @current_user&.admin?
    @current_user&.id == @game.gm_id
  end
end
