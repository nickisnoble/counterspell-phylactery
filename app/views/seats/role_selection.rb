# frozen_string_literal: true

class Views::Seats::RoleSelection < Phlex::HTML
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::RadioButtonTag

  ROLE_CONFIG = {
    "striker" => { icon: "fa-sword", label: "Striker" },
    "protector" => { icon: "fa-shield", label: "Protector" },
    "charmer" => { icon: "fa-masks-theater", label: "Charmer" },
    "strategist" => { icon: "fa-chess-knight", label: "Strategist" }
  }.freeze

  def initialize(game:, role_counts:)
    @game = game
    @role_counts = role_counts
  end

  def view_template
    turbo_frame_tag "game_#{@game.id}_role_selection" do
      div(class: "grid grid-cols-2 gap-4") do
        ROLE_CONFIG.each do |role, config|
          render_role_option(role, config)
        end
      end
    end
  end

  private

  def render_role_option(role, config)
    count = @role_counts[role] || 0
    is_full = count >= 2
    label_class = "relative flex flex-col items-center cursor-pointer rounded-sm border border-black/10 p-4 transition #{is_full ? 'opacity-50' : 'hover:border-purple-500 hover:bg-white'} bg-white/50"

    label(class: label_class) do
      radio_button_tag "role_selection", role, false,
        class: "peer sr-only",
        required: true,
        disabled: is_full,
        data: { action: "change->wizard#roleSelected" }

      div(class: "absolute top-3 right-3 hidden peer-checked:block") do
        div(class: "w-6 h-6 bg-purple-900 rounded-full flex items-center justify-center") do
          i(class: "fa-solid fa-check text-white text-xs")
        end
      end

      div(class: "mb-3") do
        i(class: "#{config[:icon]} fa-duotone text-4xl text-purple-500")
      end

      p(class: "font-serif font-semibold text-sm text-blue-900 mb-1") { config[:label] }
      p(class: "font-serif text-xs text-blue-900/60") do
        if is_full
          "Full (2/2)"
        elsif count == 1
          "1 taken (1/2)"
        else
          "Available (0/2)"
        end
      end
    end
  end
end
