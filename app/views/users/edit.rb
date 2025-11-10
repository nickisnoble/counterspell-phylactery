# frozen_string_literal: true

class Views::Users::Edit < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::Render

  def initialize(user:)
    @user = user
  end

  def view_template
    content_for(:title, "Editing user")

    main(class: "w-full max-w-screen-sm mx-auto") do
      h1(class: "font-bold text-4xl text-balance") do
        @user.display_name.present? ? "Settings" : "Introducing our newest #{@user.system_role}:"
      end

      render Views::Users::Form.new(user: @user)
    end
  end
end
