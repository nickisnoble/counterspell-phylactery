class Components::Paper < ApplicationComponent
  def view_template(&block)
    article(class: "paper", &block)
  end
end
