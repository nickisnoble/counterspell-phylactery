class Views::Layouts::ActionText::Contents::Content < Views::Base
  def view_template(&block)
    div class: "lexxy-content" do
      yield_content(&block)
    end
  end

  private

  def yield_content(&block)
    block.call if block
  end
end
