# frozen_string_literal: true

class Components::FlashMessage < Views::Base
  def initialize(message:, type:)
    @message = message
    @type = type
  end

  # Phlex v2 feature: render? method encapsulates conditional rendering
  # Component only renders if there's a message to display
  def render?
    @message.present?
  end

  def view_template
    div(
      class: message_classes,
      id: "#{@type}_flash",
      data: {
        controller: "flash",
        flash_dismiss_after_value: 5000
      }
    ) do
      div(class: "flex items-center justify-between gap-4") do
        span { @message }
        button(
          type: "button",
          class: "text-current opacity-50 hover:opacity-100 transition-opacity",
          data: { action: "click->flash#close" },
          aria: { label: "Close" }
        ) do
          plain "×"
        end
      end
    end
  end

  private

  def message_classes
    base_classes = "inline-block self-center mb-5 px-4 py-3 rounded-md font-medium shadow-sm"

    case @type
    when :alert
      "#{base_classes} bg-red-50 text-red-800 border border-red-200"
    when :notice
      "#{base_classes} bg-green-50 text-green-800 border border-green-200"
    else
      "#{base_classes} bg-blue-50 text-blue-800 border border-blue-200"
    end
  end
end
