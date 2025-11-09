# frozen_string_literal: true

class Views::Shared::FlashTurboStream < Views::Base
  include Phlex::Rails::Helpers::TurboStreamTag

  def view_template
    # Turbo Stream to update the flash-messages div
    turbo_stream.update "flash-messages" do
      # Render flash messages if present
      render FlashMessage.new(message: alert, type: :alert)
      render FlashMessage.new(message: notice, type: :notice)
    end
  end
end
