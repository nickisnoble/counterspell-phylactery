class Views::Pages::FormComponent < Views::Base
  def initialize(page:)
    @page = page
  end

  def view_template
    form_with(model: @page, class: "contents text-left") do |form|
      render_errors(form) if @page.errors.any?

      div class: "my-5" do
        form.label :title
        form.text_field :title
      end

      div class: "my-5" do
        form.label :body
        form.rich_textarea :body
      end

      div class: "inline" do
        form.submit class: "btn"
      end
    end
  end

  private

  def render_errors(form)
    div id: "error_explanation", class: "bg-red-50 text-red-500 px-3 py-2 font-medium rounded-md mt-3" do
      h2 do
        plain pluralize(@page.errors.count, "error")
        plain " prohibited this page from being saved:"
      end

      ul class: "list-disc ml-6" do
        @page.errors.each do |error|
          li { error.full_message }
        end
      end
    end
  end
end
