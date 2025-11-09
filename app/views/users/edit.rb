class Views::Users::Edit < Views::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    content_for :title, "Editing user"

    main class: "w-full max-w-screen-sm mx-auto" do
      h1 class: "font-bold text-4xl text-balance" do
        @user.display_name.present? ? "Settings" : "Introducing our newest #{@user.system_role}:"
      end

      turbo_frame_tag dom_id(@user), data: { turbo_action: "advance" } do
        render Views::Users::FormComponent.new(user: @user)
      end
    end
  end
end
