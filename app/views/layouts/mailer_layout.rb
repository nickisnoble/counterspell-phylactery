class Views::Layouts::MailerLayout < Views::Base
  include Phlex::Rails::Layout

  def view_template(&block)
    doctype

    html do
      head do
        meta "http-equiv": "Content-Type", content: "text/html; charset=utf-8"
        style do
          raw "/* Email styles need to be inline */"
        end
      end

      body do
        yield_content(&block)
      end
    end
  end

  private

  def yield_content(&block)
    block.call
  end
end
