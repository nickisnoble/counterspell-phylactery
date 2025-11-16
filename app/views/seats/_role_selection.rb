# frozen_string_literal: true

class Views::Seats::RoleSelection < Views::Base
  include Phlex::Rails::Helpers::TurboFrameTag

  def initialize(game:, role_counts:)
    @game = game
    @role_counts = role_counts
  end

  def view_template
    turbo_frame_tag "game_#{@game.id}_role_selection" do
      div(class: "grid grid-cols-2 gap-4") do
        Hero.roles.keys.each do |role|
          render_role_option(role)
        end
      end
    end
  end

  private

  def render_role_option(role)
    count = @role_counts[role] || 0
    is_full = count >= 2

    label_class = "relative flex flex-col cursor-pointer rounded-sm border border-black/10 p-6 transition #{is_full ? 'opacity-50 cursor-not-allowed bg-gray-200' : 'hover:border-purple-500 hover:bg-white bg-white/50'}"

    label(class: label_class) do
      input(
        type: "radio",
        name: "role_selection",
        value: role,
        class: "peer sr-only",
        required: true,
        disabled: is_full,
        data: { action: "change->wizard#roleSelected" }
      )

      # Selected indicator
      div(class: "absolute top-3 right-3 hidden peer-checked:block") do
        div(class: "w-6 h-6 bg-purple-900 rounded-full flex items-center justify-center") do
          i(class: "fa-solid fa-check text-white text-xs")
        end
      end

      # Role icon based on role type
      div(class: "mb-4 text-center") do
        icon_class = case role
        when "striker" then "fa-duotone fa-sword text-5xl text-red-500"
        when "protector" then "fa-duotone fa-shield text-5xl text-blue-500"
        when "charmer" then "fa-duotone fa-masks-theater text-5xl text-purple-500"
        when "strategist" then "fa-duotone fa-chess text-5xl text-green-500"
        end
        i(class: icon_class)
      end

      # Role name
      p(class: "font-display text-xl text-blue-900 mb-2 text-center") { role.humanize }

      # Availability indicator
      color_class = is_full ? "text-red-700" : "text-blue-900/60"
      p(class: "font-serif text-sm text-center #{color_class}") do
        if is_full
          "Full (2/2)"
        else
          "#{count}/2 taken"
        end
      end
    end
  end
end
