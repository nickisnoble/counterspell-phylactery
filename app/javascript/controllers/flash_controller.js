import { Controller } from "@hotwired/stimulus"

// Auto-dismiss flash messages after a delay
export default class extends Controller {
  static values = {
    dismissAfter: { type: Number, default: 5000 } // 5 seconds default
  }

  connect() {
    // Auto-dismiss after the specified time
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, this.dismissAfterValue)
  }

  disconnect() {
    // Clear timeout if element is removed before dismiss
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    // Fade out and remove
    this.element.classList.add('opacity-0', 'transition-opacity', 'duration-500')

    setTimeout(() => {
      this.element.remove()
    }, 500)
  }

  // Allow manual dismissal (click to close)
  close(event) {
    event.preventDefault()
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
    this.dismiss()
  }
}
