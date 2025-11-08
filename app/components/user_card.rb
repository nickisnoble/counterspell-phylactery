class Components::UserCard < Views::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    div(id: dom_id(@user), class: "w-full sm:w-auto my-5 space-y-5") do
      p { @user.display_name }
    end
  end
end
