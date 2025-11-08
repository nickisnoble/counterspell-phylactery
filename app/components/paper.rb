class Components::Paper < Views::Base
  def view_template(&block)
    article(class: "paper", &block)
  end
end
