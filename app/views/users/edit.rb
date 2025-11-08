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

      render Users::FormComponent.new(user: @user)
    end
  end
end
