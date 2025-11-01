class Users::Show < ApplicationComponent
  def initialize(user:)
    @user = user
  end

  def view_template
    content_for :title, "Showing user"

    main do
      article class: "bg-white rounded-xl max-w-screen-md shadow mx-auto p-6 space-y-6" do
        h2(class: "font-bold text-4xl") { @user.display_name }

        div class: "text-left" do
          unsafe_raw @user.bio
        end
      end
    end
  end
end
