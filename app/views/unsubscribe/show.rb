# frozen_string_literal: true

class Views::Unsubscribe::Show < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(user:, token:)
    @user = user
    @token = token
  end

  def view_template
    content_for(:title, "Unsubscribe from Newsletters")

    main(class: "flex flex-col flex-1 justify-center items-center gap-8") do
      section(class: "space-y-4 max-w-[36ch] text-center *:text-pretty") do
        h1(class: "mb-8 font-display text-3xl") { "Unsubscribe from Newsletters" }

        if @user.newsletter?
          p { "Are you sure you want to unsubscribe from Counterspell newsletters?" }
          p(class: "text-sm text-gray-600") { "Email: #{@user.email}" }

          form_with url: unsubscribe_path(token: @token), method: :post, class: "mt-6 space-y-4" do |form|
            form.submit "Unsubscribe", class: "btn"
          end
        else
          p(class: "text-green-600") { "You are already unsubscribed from newsletters." }
        end
      end
    end
  end
end
