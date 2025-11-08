class Views::Dashboards::Show < Views::Base
  def initialize(current_user:)
    @current_user = current_user
  end

  def view_template
    main class: "space-y-6" do
      h1(class: "font-bold text-4xl") { "Hello, #{@current_user.display_name}!" }

      div class: "grid gap-2 md:grid-cols-2" do
        section do
          h2(class: "font-bold text-2xl mb-4") { "Content" }
          nav class: "space-y-2 *:block" do
            link_to "Heroes", heroes_path
            link_to "Traits", traits_path
            link_to "Pages", pages_path
          end
        end

        section do
          h2(class: "font-bold text-2xl mb-4") { "Site" }
          nav class: "space-y-2 *:block" do
            a href: "https://counterspell.pirsch.io/?access=PiJasRxAxTSZn6FBk2wC", target: "_blank", rel: "noopener" do
              "Analytics"
            end
          end
        end
      end
    end
  end
end
