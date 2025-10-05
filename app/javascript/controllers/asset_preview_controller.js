import { Controller } from "@hotwired/stimulus"


/*

  # Find and replace:
  #  asset_field -> field name
  #  record -> name of record eg @hero
  <%= form.label :asset_field,
      data: {
        controller: "asset-preview",
        action: "dragover->asset-preview#onDragOver dragleave->asset-preview#onDragLeave drop->asset-preview#onDrop paste->asset-preview#onPaste"
    }, class: "block" do %>
    <%= form.file_field :asset_field,
      direct_upload: true,
      data: {
        action: "change->asset-preview#update"
      },
      class: "w-full p-4 border border-dashed border-blue-500 bg-blue-500/5 hover:bg-blue-500/10 cursor-pointer#{(record.asset_field.attached? ? ' sr-only' : "")}" %>

     <%= image_tag(url_for(record.asset_field), id: "record_asset_field_preview", class: "h-auto w-full object-cover") if record.asset_field.present? %>
  <% end %>
*/

export default class extends Controller {
  connect() {
    this.input = this.element.querySelector('input[type="file"]')
  }

  update(event) {
    const file = this.input?.files?.[0];
    if (!file) return;

    const id = this.input.id;
    let preview = document.querySelector(`#${id}_preview`);

    if(!preview) {
      preview = document.createElement('img');
      preview.id = `${id}_preview`;
      this.input.insertAdjacentElement('afterend', preview);
    }

    const reader = new FileReader();
    reader.onload = () => {
      preview.src = reader.result;
      this.input.classList.add("sr-only");
    }
    reader.readAsDataURL(file);
  }

   onDragOver(e) {
    e.preventDefault()
    this.element.classList.add("bg-blue-500/10")
  }

  onDragLeave() {
    this.element.classList.remove("bg-blue-500/10")
  }

  onDrop(e) {
    e.preventDefault();
    this.onDragLeave();
    const file = e.dataTransfer?.files?.[0];
    if (!file || !this.input) return;

    const dt = new DataTransfer();
    dt.items.add(file);
    this.input.files = dt.files;
    this.update({ target: this.input });
    this.input.dispatchEvent(new Event("change", { bubbles: true }));
  }

  onPaste(e) {
    const item = [...(e.clipboardData?.items || [])].find(i => i.type.startsWith("image/"));
    if (!item || !this.input) return;

    const file = item.getAsFile();
    if (!file) return;

    const dt = new DataTransfer();
    dt.items.add(file);
    this.input.files = dt.files;
    this.update({ target: this.input });
    this.input.dispatchEvent(new Event("change", { bubbles: true }));
  }
}