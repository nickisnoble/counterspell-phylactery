class Views::Heroes::FormComponent < Views::Base
  include Phlex::Rails::Helpers::CollectionRadioButtons
  include Phlex::Rails::Helpers::SelectTag
  include Phlex::Rails::Helpers::OptionsFromCollectionForSelect
  include Phlex::Rails::Helpers::LabelTag

  def initialize(hero:)
    @hero = hero
  end

  def view_template
    form_with(model: @hero, class: "contents text-left") do |form|
      render_errors(form) if @hero.errors.any?

      div class: "my-5" do
        form.label :name
        form.text_field :name
      end

      div class: "my-5" do
        form.label :pronouns, "Pronouns"
        form.text_field :pronouns, list: "default-pronouns"
        datalist id: "default-pronouns" do
          option value: "They/Them"
          option value: "She/Her"
          option value: "He/Him"
        end
      end

      div class: "my-5" do
        form.label :role
        div class: "mt-2" do
          collection_radio_buttons(:hero, :role, Hero.roles.keys, :to_s, ->(r) { r.titleize }) do |b|
            div do
              b.radio_button
              b.label
            end
          end
        end
      end

      form.label :portrait,
        data: {
          controller: "asset-preview",
          action: "dragover->asset-preview#onDragOver dragleave->asset-preview#onDragLeave drop->asset-preview#onDrop paste->asset-preview#onPaste"
        },
        class: "my-5" do
        form.file_field :portrait,
          direct_upload: true,
          data: { action: "change->asset-preview#update" },
          class: "w-full p-4 border border-dashed border-blue-500 bg-blue-500/5 hover:bg-blue-500/10 cursor-pointer#{@hero.portrait.attached? ? ' sr-only' : ''}"

        if @hero.portrait.present?
          image_tag(url_for(@hero.portrait), id: "hero_portrait_preview", class: "h-auto w-full object-cover")
        end
      end

      div class: "my-5" do
        form.label :summary
        form.rich_text_area :summary, toolbar: false
      end

      div class: "my-5" do
        form.label :backstory
        form.rich_text_area :backstory
      end

      # Required Traits Section
      div class: "my-8" do
        h3(class: "text-lg font-medium text-gray-900 mb-4") { "Required Traits" }

        Hero::REQUIRED_TRAIT_TYPES.each do |trait_type|
          div class: "my-5" do
            label_tag "trait_ids_#{trait_type.downcase}", trait_type.titleize

            traits_for_type = Trait.where(type: trait_type).order(:name)
            existing_trait = @hero.traits.find { |t| t.type == trait_type }
            selected_value = existing_trait&.id

            select_tag "trait_ids_#{trait_type.downcase}",
              options_from_collection_for_select(traits_for_type, :id, :name, selected_value),
              { prompt: "Select #{trait_type.titleize}..." }
          end
        end
      end

      div do
        form.submit class: "btn"
      end
    end
  end

  private

  def render_errors(form)
    div id: "error_explanation", class: "bg-red-50 text-red-500 px-3 py-2 font-medium rounded-md mt-3" do
      h2 do
        plain pluralize(@hero.errors.count, "error")
        plain " prohibited this hero from being saved:"
      end

      ul class: "list-disc ml-6" do
        @hero.errors.each do |error|
          li { error.full_message }
        end
      end
    end
  end
end
