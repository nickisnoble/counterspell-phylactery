# frozen_string_literal: true

class Views::Traits::Form < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::Pluralize
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::URLFor

  def initialize(trait:)
    @trait = trait
  end

  def view_template
    form_with(model: @trait, class: "contents text-left") do |form|
      if @trait.errors.any?
        div(id: "error_explanation", class: "bg-red-50 text-red-500 px-3 py-2 font-medium rounded-md mt-3") do
          h2 { "#{pluralize(@trait.errors.count, 'error')} prohibited this trait from being saved:" }

          ul(class: "list-disc ml-6") do
            @trait.errors.each do |error|
              li { error.full_message }
            end
          end
        end
      end

      div(class: "my-5") do
        form.label :type
        form.text_field :type, list: "trait-types"
        datalist(id: "trait-types") do
          Trait.distinct.pluck(:type).compact.sort.each do |trait_type|
            option(value: trait_type)
          end
        end
      end

      form.label :cover,
        data: {
          controller: "asset-preview",
          action: "dragover->asset-preview#onDragOver dragleave->asset-preview#onDragLeave drop->asset-preview#onDrop paste->asset-preview#onPaste"
        }, class: "block" do
        span(class: "text-left") { "Cover" }
        form.file_field :cover,
          direct_upload: true,
          data: {
            action: "change->asset-preview#update"
          },
          class: "w-full p-4 border border-dashed border-blue-500 bg-blue-500/5 hover:bg-blue-500/10 cursor-pointer#{(@trait.cover.attached? ? ' sr-only' : '')}"

        if @trait.cover.present?
          image_tag(url_for(@trait.cover), id: "trait_cover_preview", class: "h-auto w-full object-cover")
        end
      end

      div(class: "my-5") do
        form.label :name
        form.text_field :name
      end

      div(class: "my-5") do
        form.label :description
        form.textarea :description, toolbar: false
      end

      div(class: "my-5", data: { controller: "abilities-editor", abilities: @trait.abilities.to_json }) do
        form.label :abilities

        div(class: "mt-2") do
          div(data: { abilities_editor_target: "container" }, class: "space-y-2")

          button(
            type: "button",
            data: { action: "click->abilities-editor#addAbility" }
          ) { "+ Add Ability" }
        end

        template(data: { abilities_editor_target: "template" }) do
          div(class: "ability-row") do
            input(
              type: "text",
              placeholder: "Ability name",
              class: "ability-key",
              required: true
            )
            input(
              type: "text",
              placeholder: "Description",
              class: "ability-value",
              required: true
            )
            button(
              type: "button",
              data: { action: "click->abilities-editor#removeAbility" }
            ) { "Remove" }
          end
        end
      end

      div do
        form.submit class: "btn"
      end
    end
  end
end
