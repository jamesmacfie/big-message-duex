import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["container", "form", "input"]
  static values = {
    channelId: Number,
    currentPersonId: Number
  }

  connect() {
    this.subscription = consumer.subscriptions.create(
      { channel: "ChatRoomChannel", channel_id: this.channelIdValue },
      {
        connected: this._connected.bind(this),
        disconnected: this._disconnected.bind(this),
        received: this._received.bind(this)
      }
    )

    // Scroll to bottom on load
    setTimeout(() => this.scrollToBottom(), 100)

    // Listen for turbo:submit-end to scroll after form submission
    this.element.addEventListener('turbo:submit-end', () => {
      setTimeout(() => this.scrollToBottom(), 100)
    })
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  _connected() {
    console.log("Connected to chat room")
  }

  _disconnected() {
    console.log("Disconnected from chat room")
  }

  _received(data) {
    // Append message from other users (current user's message shown via Turbo Stream)
    if (data.sender_id !== this.currentPersonIdValue) {
      this.containerTarget.insertAdjacentHTML("beforeend", data.message)
      setTimeout(() => this.scrollToBottom(), 100)
    }
  }

  scrollToBottom() {
    if (this.hasContainerTarget) {
      const messagesArea = this.containerTarget.closest('.overflow-y-auto')
      if (messagesArea) {
        messagesArea.scrollTop = messagesArea.scrollHeight
      }
    }
  }

  resetForm(event) {
    // Reset form after successful submission
    if (this.hasInputTarget && this.hasFormTarget) {
      this.inputTarget.value = ''
    }
  }
}
