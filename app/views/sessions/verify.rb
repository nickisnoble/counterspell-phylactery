# frozen_string_literal: true

class Views::Sessions::Verify < Views::Base
  include Phlex::Rails::Helpers::FormWith

  def initialize
  end

  def view_template
    main(class: "flex-1 flex flex-col justify-center items-center") do
      h1(class: "text-3xl font-bold mb-2") { "The Doortal Awaits..." }
      p(class: "text-balance mb-2 max-w-[36ch]") do
        plain "Runes were conjured and sent to #{session[:awaiting_login]} — please cast them hence:"
      end

      form_with url: validate_session_path, data: { turbo_frame: "_top" } do |f|
        f.text_field :code, required: true, placeholder: "000000", class: "text-center fun-interaction"
      end
    end
  end
end
