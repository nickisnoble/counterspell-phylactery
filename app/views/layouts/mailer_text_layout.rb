class Layouts::MailerTextLayout < ApplicationComponent
  include Phlex::Rails::Layout

  def view_template(&block)
    yield_content(&block)
  end

  private

  def yield_content(&block)
    block.call
  end
end
