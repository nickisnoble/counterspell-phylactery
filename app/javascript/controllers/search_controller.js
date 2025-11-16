import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["input", "table"]

  filter() {
    const filterValue = this.inputTarget.value.toLowerCase()
    const rows = this.tableTarget.getElementsByTagName('tbody')[0].getElementsByTagName('tr')

    for (let row of rows) {
      const text = row.textContent.toLowerCase()
      row.style.display = text.includes(filterValue) ? '' : 'none'
    }
  }
}
