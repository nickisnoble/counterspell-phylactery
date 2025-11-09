# frozen_string_literal: true

class Views::Users::FormFrame < Views::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    turbo_frame_tag dom_id(@user) do
      render Views::Users::FormComponent.new(user: @user)
    end
  end
end
