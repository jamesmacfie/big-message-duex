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
      if (data.type === "thread_reply") {
        // Handle thread reply
        const threadContainer = document.getElementById(`thread-replies-${data.parent_message_id}`)
        if (threadContainer) {
          // Remove "No replies yet" message if it exists
          const noRepliesMsg = document.getElementById(`no-replies-${data.parent_message_id}`)
          if (noRepliesMsg) {
            noRepliesMsg.remove()
          }
          threadContainer.insertAdjacentHTML("beforeend", data.reply)
        }
        // Update the thread indicator on the parent message
        this.updateThreadIndicator(data.parent_message_id)
      } else {
        // Handle regular message
        this.containerTarget.insertAdjacentHTML("beforeend", data.message)
        setTimeout(() => this.scrollToBottom(), 100)
      }
    }
  }

  updateThreadIndicator(messageId) {
    // Fetch and update the thread indicator for the parent message
    const indicatorElement = document.getElementById(`thread-indicator-${messageId}`)
    if (!indicatorElement) return

    const channelId = this.channelIdValue
    fetch(`/channels/${channelId}/messages/${messageId}/thread_indicator`)
      .then(response => response.text())
      .then(html => {
        indicatorElement.outerHTML = html
      })
      .catch(error => {
        console.error('Error updating thread indicator:', error)
      })
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
    if (event.detail.success !== false) {
      if (this.hasInputTarget && this.hasFormTarget) {
        this.inputTarget.value = ''
        this.inputTarget.focus()
      }
    }
  }

  handleKeydown(event) {
    // Submit on Cmd+Enter or Ctrl+Enter
    if ((event.metaKey || event.ctrlKey) && event.key === 'Enter') {
      event.preventDefault()
      if (this.hasFormTarget) {
        this.formTarget.requestSubmit()
      }
    }
  }
}
