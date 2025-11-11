# frozen_string_literal: true

class Components::PageStack < Components::Base
  def initialize(title: nil, **attributes)
    @title = title
    @attributes = attributes
  end

  def view_template(&block)
    main(class: "mx-auto w-full max-w-4xl", **@attributes) do
      article(class: "paper") do
        h1(class: "mb-6 font-bold text-gray-900 text-3xl text-center") { @title } if @title
        yield if block_given?
      end
    end
  end
end
