class Views::Users::FormComponent < Views::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    form_with(model: @user, class: "space-y-5 py-4 text-left") do |form|
      render_errors(form) if @user.errors.any?

      div do
        form.label :display_name, "Full Name"
        form.text_field :display_name, required: true
      end

      div do
        form.label :pronouns, "Preferred Pronouns"
        form.text_field :pronouns, list: "default-pronouns"
        datalist id: "default-pronouns" do
          option value: "They/Them"
          option value: "She/Her"
          option value: "He/Him"
        end
      end

      div do
        form.label :email
        form.text_field :email, disabled: true, title: "Contact Nick or Marnie if you need to change your email!"

        form.label :newsletter, class: "font-normal flex gap-2 items-center mt-1" do
          form.checkbox :newsletter, class: "accent-yellow-500 size-4"
          plain " Email me about upcoming game sessions and more."
        end
      end

      div do
        form.label :bio, bio_label_text

        form.rich_text_area :bio
      end

      form.submit "Save Preferences", class: "btn"
    end
  end

  private

  def bio_label_text
    if helpers.Current.user.admin?
      "What would you like our players to know about you?"
    elsif helpers.Current.user.gm?
      "What would you like players to know about you?"
    else
      "What would you like our event staff to know about you?"
    end
  end

  def render_errors(form)
    div id: "error_explanation", class: "bg-red-50 text-red-500 px-3 py-2 font-medium rounded-md mt-3" do
      h2 do
        plain pluralize(@user.errors.count, "error")
        plain " prohibited preferences from being saved:"
      end

      ul class: "list-disc ml-6" do
        @user.errors.each do |error|
          li { error.full_message }
        end
      end
    end
  end
end
