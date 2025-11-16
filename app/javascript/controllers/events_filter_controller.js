import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "section"]
  static values = { current: String }

  connect() {
    // Set initial filter to "upcoming" if not set
    if (!this.currentValue) {
      this.currentValue = "upcoming"
    }
    this.filterSections()
  }

  filter(event) {
    event.preventDefault()
    const status = event.currentTarget.dataset.status
    this.currentValue = status
    this.filterSections()
  }

  filterSections() {
    // Update tab styles
    this.tabTargets.forEach(tab => {
      const status = tab.dataset.status
      if (status === this.currentValue) {
        // Active tab
        tab.classList.remove("text-blue-900/60", "hover:text-blue-900", "hover:bg-white", "border-transparent", "hover:border-black/10")
        tab.classList.add("text-blue-900", "bg-white", "border-black/10")
      } else {
        // Inactive tab
        tab.classList.remove("text-blue-900", "bg-white", "border-black/10")
        tab.classList.add("text-blue-900/60", "hover:text-blue-900", "hover:bg-white", "border-transparent", "hover:border-black/10")
      }
    })

    // Show/hide sections
    this.sectionTargets.forEach(section => {
      const status = section.dataset.status
      if (status === this.currentValue) {
        section.classList.remove("hidden")
      } else {
        section.classList.add("hidden")
      }
    })
  }
}
