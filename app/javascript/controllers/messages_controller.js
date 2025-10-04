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
    // Handle message updates
    if (data.type === "message_updated") {
      if (data.sender_id !== this.currentPersonIdValue) {
        const messageElement = document.getElementById(`message-${data.message_id}`)
        if (messageElement) {
          // Fetch the updated message HTML
          const channelId = this.channelIdValue
          fetch(`/channels/${channelId}/messages/${data.message_id}`)
            .then(response => response.text())
            .then(html => {
              messageElement.outerHTML = html
            })
            .catch(error => console.error('Error updating message:', error))
        }
      }
      return
    }

    // Handle message deletion
    if (data.type === "message_deleted") {
      if (data.sender_id !== this.currentPersonIdValue) {
        const messageElement = document.getElementById(`message-${data.message_id}`)
        if (messageElement) {
          // Fetch the updated message HTML
          const channelId = this.channelIdValue
          fetch(`/channels/${channelId}/messages/${data.message_id}`)
            .then(response => response.text())
            .then(html => {
              messageElement.outerHTML = html
            })
            .catch(error => console.error('Error deleting message:', error))
        }
      }
      return
    }

    // Handle reaction updates
    if (data.type === "reaction_added" || data.type === "reaction_removed") {
      if (data.sender_id !== this.currentPersonIdValue) {
        this.updateReactions(data.message_id)
      }
      return
    }

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

  updateReactions(messageId) {
    // Fetch and update reactions for a message
    const reactionsElement = document.getElementById(`reactions-${messageId}`)
    if (!reactionsElement) return

    fetch(`/messages/${messageId}/reactions_partial`)
      .then(response => response.text())
      .then(html => {
        reactionsElement.outerHTML = html
      })
      .catch(error => {
        console.error('Error updating reactions:', error)
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
