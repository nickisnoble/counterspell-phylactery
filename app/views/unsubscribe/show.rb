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
      section(class: "space-y-4 max-w-[48ch] *:text-pretty") do
        h1(class: "mb-8 font-display text-3xl text-center") { "Unsubscribe from Newsletters" }

        if @user.newsletter?
          p(class: "text-center") { "We're sorry to see you go. Please help us improve by letting us know why you're unsubscribing:" }
          p(class: "text-sm text-gray-600 text-center") { "Email: #{@user.email}" }

          form_with url: unsubscribe_path(token: @token), method: :post, class: "mt-6 space-y-6" do |form|
            div(class: "space-y-3") do
              UnsubscribeEvent::REASONS.each do |reason|
                label(class: "flex items-center gap-3 cursor-pointer hover:bg-gray-50 p-2 rounded") do
                  input(type: "radio", name: "reason", value: reason, class: "cursor-pointer")
                  span(class: "text-sm") { reason_text(reason) }
                end
              end
            end

            div(class: "flex justify-center") do
              form.submit "Unsubscribe", class: "btn"
            end
          end
        else
          p(class: "text-green-600 text-center") { "You are already unsubscribed from newsletters." }
        end
      end
    end
  end

  private

  def reason_text(reason)
    case reason
    when "too_many_emails"
      "I receive too many emails"
    when "not_relevant"
      "The content is not relevant to me"
    when "never_subscribed"
      "I never subscribed to this list"
    when "privacy_concerns"
      "I have privacy concerns"
    when "other"
      "Other reason"
    end
  end
end
