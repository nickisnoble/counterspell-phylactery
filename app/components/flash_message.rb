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
    p class: message_classes, id: "#{@type}_flash" do
      @message
    end
  end

  private

  def message_classes
    base_classes = "inline-block self-center mb-5 px-3 py-2 rounded-md font-medium"

    case @type
    when :alert
      "#{base_classes} bg-red-50 text-red-500"
    when :notice
      "#{base_classes} bg-green-50 text-green-500"
    else
      "#{base_classes} bg-blue-50 text-blue-500"
    end
  end
end
