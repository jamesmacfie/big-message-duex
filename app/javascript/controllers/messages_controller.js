import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["container", "form", "input", "typingIndicator"]
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

    // Track typing people
    this.typingPeople = new Set()
    this.typingTimeout = null
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
    // Handle typing indicators
    if (data.type === "typing") {
      if (data.person_id !== this.currentPersonIdValue) {
        this.addTypingPerson(data.person_id, data.person_name)
      }
      return
    }

    if (data.type === "stop_typing") {
      if (data.person_id !== this.currentPersonIdValue) {
        this.removeTypingPerson(data.person_id)
      }
      return
    }

    // Update sidebar unread count for new messages from other users
    if (data.type === "message" && data.sender_id !== this.currentPersonIdValue && data.channel_id) {
      this.incrementSidebarBadge(data.channel_id)
    }

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
      // Stop typing indicator when message is sent
      this.stopTyping()
      if (this.typingTimeout) {
        clearTimeout(this.typingTimeout)
        this.typingTimeout = null
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

  handleInput(event) {
    // Send typing indicator (throttled)
    if (this.subscription) {
      this.sendTyping()
    }
  }

  sendTyping() {
    // Clear any existing timeout
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout)
    }

    // Send typing event
    this.subscription.perform("typing", { person_id: this.currentPersonIdValue })

    // Set timeout to stop typing after 3 seconds of inactivity
    this.typingTimeout = setTimeout(() => {
      this.stopTyping()
    }, 3000)
  }

  stopTyping() {
    if (this.subscription) {
      this.subscription.perform("stop_typing", { person_id: this.currentPersonIdValue })
    }
  }

  addTypingPerson(personId, personName) {
    this.typingPeople.add({ id: personId, name: personName })
    this.updateTypingIndicator()

    // Auto-remove after 5 seconds
    setTimeout(() => {
      this.removeTypingPerson(personId)
    }, 5000)
  }

  removeTypingPerson(personId) {
    this.typingPeople = new Set(
      Array.from(this.typingPeople).filter(p => p.id !== personId)
    )
    this.updateTypingIndicator()
  }

  updateTypingIndicator() {
    if (!this.hasTypingIndicatorTarget) return

    const typingArray = Array.from(this.typingPeople)

    if (typingArray.length === 0) {
      this.typingIndicatorTarget.classList.add('hidden')
      this.typingIndicatorTarget.textContent = ''
    } else if (typingArray.length === 1) {
      this.typingIndicatorTarget.classList.remove('hidden')
      this.typingIndicatorTarget.textContent = `${typingArray[0].name} is typing...`
    } else if (typingArray.length === 2) {
      this.typingIndicatorTarget.classList.remove('hidden')
      this.typingIndicatorTarget.textContent = `${typingArray[0].name} and ${typingArray[1].name} are typing...`
    } else {
      this.typingIndicatorTarget.classList.remove('hidden')
      this.typingIndicatorTarget.textContent = `${typingArray.length} people are typing...`
    }
  }

  incrementSidebarBadge(channelId) {
    // Only update if we're not currently viewing this channel
    if (channelId === this.channelIdValue) {
      return
    }

    const sidebarLink = document.querySelector(`a[href="/channels/${channelId}"]`)
    if (!sidebarLink) return

    const badgeContainer = sidebarLink.querySelector('.flex.items-center.justify-between')
    if (!badgeContainer) return

    let badge = badgeContainer.querySelector('.bg-red-600')
    const channelNameSpan = badgeContainer.querySelector('span:not(.text-gray-400):not(.bg-red-600)')

    if (badge) {
      // Increment existing badge
      const currentCount = parseInt(badge.textContent) || 0
      badge.textContent = currentCount + 1
    } else {
      // Create new badge
      badge = document.createElement('span')
      badge.className = 'inline-flex items-center justify-center px-2 py-0.5 text-xs font-bold leading-none text-white bg-red-600 rounded-full'
      badge.textContent = '1'
      badgeContainer.appendChild(badge)
    }

    // Make channel name bold
    if (channelNameSpan) {
      channelNameSpan.classList.add('font-bold')
    }
  }
}
