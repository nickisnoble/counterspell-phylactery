# frozen_string_literal: true

class Views::Components::CheckinButton < Views::Base
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::TurboFrameTag

  def initialize(seat:, variant: :default)
    @seat = seat
    @variant = variant
  end

  def view_template
    turbo_frame_tag("checkin_seat_#{@seat.id}") do
      case @variant
      when :compact
        render_compact_button
      when :card
        render_card_button
      else
        render_default_button
      end
    end
  end

  private

  def render_compact_button
    # For table rows in checkins#show
    button_to(
      @seat.checked_in? ? "Undo" : "Check In",
      checkin_seat_path(@seat),
      method: :patch,
      class: "px-3 py-1 #{@seat.checked_in? ? 'bg-blue-900/60 hover:bg-blue-900/80' : 'btn'} text-white text-xs font-serif font-medium rounded-sm cursor-pointer"
    )
  end

  def render_card_button
    # For seat cards in games#show with status display
    div(class: "flex flex-col items-end gap-2") do
      if @seat.checked_in?
        div(class: "text-right") do
          div(class: "mb-2 text-sm font-serif font-semibold text-emerald-700 flex items-center gap-1") do
            i(class: "fa-solid fa-check")
            plain "Checked in"
          end
          if @seat.checked_in_at
            div(class: "mb-2 text-xs font-serif text-blue-900/60") { @seat.checked_in_at.strftime("%I:%M %p") }
          end
        end
        button_to(
          "Undo",
          checkin_seat_path(@seat),
          method: :patch,
          class: "btn-secondary px-3 py-1.5 text-sm font-serif font-medium cursor-pointer"
        )
      else
        button_to(
          "Check In",
          checkin_seat_path(@seat),
          method: :patch,
          class: "btn px-4 py-2 font-serif font-semibold cursor-pointer"
        )
      end
    end
  end

  def render_default_button
    # Simple button, no status display
    button_to(
      @seat.checked_in? ? "Undo Check-in" : "Check In",
      checkin_seat_path(@seat),
      method: :patch,
      class: @seat.checked_in? ? "btn-secondary" : "btn"
    )
  end
end
