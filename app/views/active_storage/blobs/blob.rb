class ActiveStorage::Blobs::Blob < ApplicationComponent
  include Phlex::Rails::Helpers::NumberToHumanSize

  def initialize(blob:, in_gallery: false)
    @blob = blob
    @in_gallery = in_gallery
  end

  def view_template
    figure class: "attachment attachment--#{@blob.representable? ? 'preview' : 'file'} attachment--#{@blob.filename.extension}" do
      if @blob.representable?
        image_tag @blob.representation(resize_to_limit: @in_gallery ? [800, 600] : [1024, 768])
      end

      figcaption class: "attachment__caption" do
        if (caption = @blob.try(:caption))
          plain caption
        else
          span(class: "attachment__name") { @blob.filename }
          span(class: "attachment__size") { number_to_human_size(@blob.byte_size) }
        end
      end
    end
  end
end
