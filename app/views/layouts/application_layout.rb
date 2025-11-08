class Views::Layouts::ApplicationLayout < Views::Base
  include Phlex::Rails::Layout

  def view_template(&block)
    doctype

    html do
      head do
        title { content_for(:title) || "Counterspell Games" }
        meta name: "viewport", content: "width=device-width,initial-scale=1"
        meta name: "apple-mobile-web-app-capable", content: "yes"
        meta name: "mobile-web-app-capable", content: "yes"
        csrf_meta_tags
        csp_meta_tag

        meta name: "image", content: "https://counterspell.games/og-image.jpg"
        meta name: "description", content: "Play table top adventures irl, whether you're a complete beginner or new to the hobby, there's a place in our world for you."

        meta property: "og:url", content: "https://counterspell.games"
        meta property: "og:type", content: "website"
        meta property: "og:title", content: "Counterspell Games"
        meta property: "og:description", content: "Play table top adventures irl, whether you're a complete beginner or new to the hobby, there's a place in our world for you."
        meta property: "og:image", content: "https://counterspell.games/og-image.jpg"

        meta name: "twitter:card", content: "summary_large_image"
        meta property: "twitter:domain", content: "counterspell.games"
        meta property: "twitter:url", content: "https://counterspell.games"
        meta name: "twitter:title", content: "Counterspell Games"
        meta name: "twitter:description", content: "Play table top adventures irl, whether you're a complete beginner or new to the hobby, there's a place in our world for you."
        meta name: "twitter:image", content: "https://counterspell.games/og-image.jpg"

        raw content_for(:head)

        link rel: "icon", href: "/icon.png", type: "image/png"
        link rel: "icon", href: "/icon.svg", type: "image/svg+xml"
        link rel: "apple-touch-icon", href: "/icon.png"

        stylesheet_link_tag :app, "data-turbo-track": "reload"
        stylesheet_link_tag "lexxy"

        javascript_importmap_tags
        script src: "https://kit.fontawesome.com/8bcb00a03e.js", crossorigin: "anonymous"

        if Rails.env.production?
          script defer: true, src: "https://api.pirsch.io/pa.js", id: "pianjs", "data-code": "oKRec8iQLQgKJr21uIOfvES9jNpmrB3P"
        end
      end

      body class: "flex flex-col gap-8 bg-amber-50 p-6 min-h-screen font-serif text-blue-900 text-center" do
        render_header
        render_flash
        yield_content(&block)
        render_footer
      end
    end
  end

  private

  def render_header
    header class: "flex flex-col justify-center items-center gap-2" do
      link_to events_path, class: "block h-20" do
        image_tag "counterspell-icon.svg", class: "h-full drop-shadow rotate-0 transition-transform transition-discrete transition-[filter] hover:rotate-3 hover:scale-110 hover:drop-shadow-lg"
      end

      if authenticated?
        nav class: "flex justify-self-end gap-4" do
          link_to "Admin Dash", dashboard_path if Current.user.admin?
          link_to "Preferences", edit_user_path(Current.user)
          button_to "Logout", session_path, method: :delete, class: "inline link"
        end
      end
    end
  end

  def render_flash
    if alert.present?
      p class: "inline-block self-center bg-red-50 mb-5 px-3 py-2 rounded-md font-medium text-red-500", id: "notice" do
        alert
      end
    end

    if notice.present?
      p class: "inline-block self-center bg-green-50 mb-5 px-3 py-2 rounded-md font-medium text-green-500", id: "notice" do
        notice
      end
    end
  end

  def render_footer
    footer class: "flex max-sm:flex-col justify-center items-center gap-2 mt-auto text-xs text-center" do
      p(class: "text-balance") { "©2025 Counterspell Games LLC, all rights reserved." }
      nav class: "flex justify-center items-center gap-1.5" do
        Page.all.each do |page|
          link_to page.title, page_path(page)
        end
      end
    end
  end

  def yield_content(&block)
    block.call
  end
end
