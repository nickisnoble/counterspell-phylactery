# frozen_string_literal: true

class Views::Users::Form < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::Pluralize

  def initialize(user:)
    @user = user
  end

  def view_template
    form_with(model: @user, class: "space-y-5 py-4 text-left") do |form|
      if @user.errors.any?
        div(id: "error_explanation", class: "bg-red-50 text-red-500 px-3 py-2 font-medium rounded-md mt-3") do
          h2 { "#{pluralize(@user.errors.count, 'error')} prohibited preferences from being saved:" }

          ul(class: "list-disc ml-6") do
            @user.errors.each do |error|
              li { error.full_message }
            end
          end
        end
      end

      div do
        form.label :display_name, "Full Name"
        form.text_field :display_name, required: true
      end

      div do
        form.label :pronouns, "Preferred Pronouns"
        form.text_field :pronouns, list: "default-pronouns"
        datalist(id: "default-pronouns") do
          option(value: "They/Them")
          option(value: "She/Her")
          option(value: "He/Him")
        end
      end

      div do
        form.label :email
        form.text_field :email, disabled: true, title: "Contact Nick or Marnie if you need to change your email!"

        div(data: { controller: "newsletter", newsletter_was_checked_value: @user.newsletter? }) do
          form.label :newsletter, class: "font-normal flex gap-2 items-center mt-1" do
            form.checkbox :newsletter, class: "accent-yellow-500 size-4", data: { newsletter_target: "checkbox", action: "change->newsletter#handleChange" }
            plain " Email me about upcoming game sessions and more."
          end

          # Unsubscribe confirmation modal
          div(data: { newsletter_target: "modal" }, class: "hidden fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50") do
            div(class: "bg-white rounded-lg p-6 max-w-md mx-4 shadow-xl") do
              div(class: "flex items-start gap-4") do
                # Icon
                div(class: "flex-shrink-0") do
                  i(class: "fas fa-exclamation-triangle text-yellow-500 text-2xl")
                end

                # Content
                div(class: "flex-1") do
                  h3(class: "text-lg font-semibold mb-2") { "Unsubscribe from newsletter?" }
                  p(class: "text-gray-600 mb-4") do
                    plain "You'll no longer receive emails about upcoming game sessions, events, and other updates. You can always resubscribe later."
                  end

                  # Buttons
                  div(class: "flex gap-3 justify-end") do
                    button(type: "button", class: "px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-md", data: { action: "click->newsletter#cancel" }) do
                      plain "Keep subscription"
                    end
                    button(type: "button", class: "px-4 py-2 bg-red-600 text-white hover:bg-red-700 rounded-md", data: { action: "click->newsletter#confirm" }) do
                      plain "Unsubscribe"
                    end
                  end
                end
              end
            end
          end
        end
      end

      div do
        bio_label_text = "What would you like #{
          Current.user.admin? ?
            'our players'
          : Current.user.gm? ?
            'players'
          : 'our event staff'
        } to know about you?"

        form.label :bio, bio_label_text
        form.rich_text_area :bio
      end

      form.submit "Save Preferences", class: "btn"
    end
  end
end
