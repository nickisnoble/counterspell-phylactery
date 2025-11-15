import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  connect() {
    const eventId = this.element.dataset.eventId
    if (!eventId) return

    this.consumer = createConsumer()
    this.subscription = this.consumer.subscriptions.create(
      { channel: "EventChannel", event_id: eventId },
      {
        received: (data) => this.handleUpdate(data)
      }
    )
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    if (this.consumer) {
      this.consumer.disconnect()
    }
  }

  handleUpdate(data) {
    if (data.type === "check_in") {
      this.handleCheckInUpdate(data)
    } else if (data.type === "seat_purchased") {
      this.handleSeatPurchase(data)
    }
  }

  handleCheckInUpdate(data) {
    // Reload the page to show updated check-in status
    // In the future, we could make this more granular by updating just the specific row
    window.location.reload()
  }

  handleSeatPurchase(data) {
    // Reload the page to show updated hero availability
    window.location.reload()
  }
}
