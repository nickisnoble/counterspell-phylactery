import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="event-search"
export default class extends Controller {
  static targets = ["input", "hidden", "list"]
  static values = { url: String }

  search() {
    const query = this.inputTarget.value.trim()
    this.hiddenTarget.value = ""
    if (query.length < 2) {
      this.listTarget.innerHTML = ""
      return
    }

    fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(events => {
        this.listTarget.innerHTML = ""
        events.forEach(event => {
          const option = document.createElement("option")
          option.value = `${event.name} (${event.date})`
          option.dataset.id = event.id
          this.listTarget.appendChild(option)
        })
      })
  }

  select() {
    const value = this.inputTarget.value
    const match = Array.from(this.listTarget.options).find(option => option.value === value)
    this.hiddenTarget.value = match ? match.dataset.id : ""
  }
}
