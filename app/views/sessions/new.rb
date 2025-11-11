# frozen_string_literal: true

class Views::Sessions::New < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::CheckboxTag
  include Phlex::Rails::Helpers::JavascriptIncludeTag

  def initialize
  end

  def view_template
    main(class: "flex flex-col flex-1 justify-center items-center gap-8") do
      section(class: "space-y-4 max-w-[36ch] text-center *:text-pretty") do
        h1(class: "mb-8 font-display text-3xl") { "Welcome to Counterspell Games" }

        p do
          plain "We're bringing the magic of Table-Top RPGs to beginners though our guided, in-person & "
          abbr(title: "in real life") { "irl" }
          plain " events."
        end

        p do
          plain "If you've always wanted to play a game like "
          a(title: "Dungeons & Dragons", href: "https://en.wikipedia.org/wiki/Dungeons_%26_Dragons") { "D&D" }
          plain " or "
          a(href: "https://en.wikipedia.org/wiki/Daggerheart") { "Daggerheart" }
          plain ", but never had the time, the place, or a guide to light the way, now is your moment."
        end

        p(class: "font-bold") { "There is a place at our table for all!" }
      end

      ul(class: "grid grid-cols-2 md:grid-cols-4 my-6 *:max-w-[3in] text-sm text-left") do
        li(class: "bg-white shadow px-2 md:px-4 py-4 md:py-6 border border-black/10 rounded-sm -rotate-1 md:-rotate-2 md:translate-y-2") do
          i(class: "mb-4 text-emerald-600 fa-scroll-old fa-regular fa-duotone")
          h3(class: "mb-1 font-bold text-emerald-600 text-xl") { "One story. One sitting." }
          p do
            plain "Each game session is a self-contained story arc that unfolds across one afternoon. Your actions will shape the world, so no two are alike. "
            em { "What will be your next adventure?" }
          end
        end

        li(class: "bg-white shadow px-2 md:px-4 py-4 md:py-6 border border-black/10 rounded-sm rotate-1 md:-rotate-1") do
          i(class: "mb-4 text-pink-700 fa-regular fa-duotone fa-swords")
          h3(class: "mb-1 font-bold text-pink-700 text-xl") { "Choose your hero." }
          p do
            plain "Our playable characters come complete with deep backstories, signature equipment & weapons, and unique abilities. "
            em { "Their destiny is in your hands!" }
          end
        end

        li(class: "bg-white shadow px-2 md:px-4 py-4 md:py-6 border border-black/10 rounded-sm -rotate-1 md:rotate-1") do
          i(class: "mb-4 text-purple-700 fa-regular fa-duotone fa-planet-ringed")
          h3(class: "mb-1 font-bold text-purple-700 text-xl") { "Enter the Rift." }
          p do
            plain "From space fairing mages to garden moons, musical weaponry and ancestry woven as scarves, The Rift is a place of endless possibilities. "
            em { "What will you discover?" }
          end
        end

        li(class: "bg-white shadow px-2 md:px-4 py-4 md:py-6 border border-black/10 rounded-sm rotate-1 md:rotate-2 md:translate-y-2") do
          i(class: "mb-4 text-sky-700 fa-regular fa-duotone fa-dice")
          h3(class: "mb-1 font-bold text-sky-700 text-xl") { "Play together, for real." }
          p do
            plain "Counterspell events are completely in person. Take a break from notifications, meet new people, and share a creative experience. "
            em { "No screens, no stress." }
          end
        end
      end

      section(class: "space-y-6 text-center") do
        p(class: "text-xl text-center") do
          plain "The Rift awaits. What will be "
          em { "your" }
          plain " story?"
        end

        form_with url: session_path, class: "space-y-2" do |form|
          raw helpers.hashcash_hidden_field_tag

          form.email_field :email,
            required: true,
            placeholder: "Enter your email address",
            class: "text-center fun-interaction"

          label(for: "agree_to_terms", class: "flex justify-center items-center gap-2 font-light italic") do
            raw checkbox_tag(:agree_to_terms, "yes", true, required: true, class: "accent-purple-700 size-4")
            span do
              plain "I agree to Counterspell's "
              raw link_to("Privacy Policy", page_path("privacy-policy"))
              plain "."
            end
          end

          form.submit "Start your Journey", class: "btn mt-4"
        end
      end
    end

    raw javascript_include_tag("hashcash", defer: true)
  end
end
