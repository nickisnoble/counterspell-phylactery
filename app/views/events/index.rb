class Views::Events::Index < Views::Base
  def view_template
    main class: "flex-1 flex flex-col gap-8" do
      h1(class: "font-bold text-3xl") { "Upcoming Sessions" }

      iframe(
        class: "w-full h-full flex-1 rounded-xl shadow-lg border border-black/10",
        src: "https://luma.com/embed/calendar/cal-fT3eKMrCO9zUul2/events",
        frameborder: "0",
        allowfullscreen: "",
        "aria-hidden": "false",
        tabindex: "0"
      )
    end
  end
end
