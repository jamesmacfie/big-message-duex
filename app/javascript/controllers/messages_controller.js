import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["container", "form", "input", "typingIndicator"]
  static values = {
    channelId: Number,
    currentPersonId: Number
  }

  connect() {
    console.log(`[MessagesController] Connecting to channel ${this.channelIdValue}`)

    // Track typing people (Map: personId -> personName)
    this.typingPeople = new Map()
    this.typingTimeouts = new Map()
    this.typingTimeout = null
    this.isTyping = false
    this.connectionAttempts = 0
    this.maxConnectionAttempts = 5

    // Create subscription
    this.createSubscription()

    // Scroll to bottom on load
    setTimeout(() => this.scrollToBottom(), 100)

    // Listen for turbo:submit-end to scroll after form submission
    this.turboSubmitHandler = () => {
      setTimeout(() => this.scrollToBottom(), 100)
    }
    this.element.addEventListener('turbo:submit-end', this.turboSubmitHandler)

    // Listen for turbo:before-cache to cleanup before page is cached
    this.turboBeforeCacheHandler = () => {
      console.log('[MessagesController] Turbo caching, cleaning up')
      this.disconnect()
    }
    document.addEventListener('turbo:before-cache', this.turboBeforeCacheHandler)
  }

  createSubscription() {
    // Remove existing subscription if any
    if (this.subscription) {
      console.log('[MessagesController] Removing existing subscription')
      this.subscription.unsubscribe()
      this.subscription = null
    }

    console.log(`[MessagesController] Creating subscription for channel ${this.channelIdValue}`)
    this.subscription = consumer.subscriptions.create(
      { channel: "ChatRoomChannel", channel_id: this.channelIdValue },
      {
        connected: this._connected.bind(this),
        disconnected: this._disconnected.bind(this),
        received: this._received.bind(this),
        rejected: this._rejected.bind(this)
      }
    )
  }

  disconnect() {
    console.log('[MessagesController] Disconnecting')

    // Stop typing indicator before unsubscribing
    if (this.subscription && this.isTyping) {
      this.stopTyping()
    }

    // Clear all timeouts
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout)
      this.typingTimeout = null
    }
    if (this.typingTimeouts) {
      this.typingTimeouts.forEach(timeout => clearTimeout(timeout))
      this.typingTimeouts.clear()
    }

    // Remove event listeners
    if (this.turboSubmitHandler) {
      this.element.removeEventListener('turbo:submit-end', this.turboSubmitHandler)
    }
    if (this.turboBeforeCacheHandler) {
      document.removeEventListener('turbo:before-cache', this.turboBeforeCacheHandler)
    }

    // Unsubscribe from Action Cable
    if (this.subscription) {
      this.subscription.unsubscribe()
      this.subscription = null
    }
  }

  _connected() {
    console.log(`[MessagesController] Connected to chat room channel ${this.channelIdValue}`)
    this.connectionAttempts = 0

    // Optionally show connection status in UI
    this.showConnectionStatus('connected')
  }

  _disconnected() {
    console.log(`[MessagesController] Disconnected from chat room channel ${this.channelIdValue}`)
    this.showConnectionStatus('disconnected')

    // Attempt to reconnect
    if (this.connectionAttempts < this.maxConnectionAttempts) {
      this.connectionAttempts++
      const delay = Math.min(1000 * Math.pow(2, this.connectionAttempts), 10000)
      console.log(`[MessagesController] Reconnecting in ${delay}ms (attempt ${this.connectionAttempts})`)

      setTimeout(() => {
        if (this.element.isConnected) {
          this.createSubscription()
        }
      }, delay)
    }
  }

  _rejected() {
    console.error(`[MessagesController] Subscription rejected for channel ${this.channelIdValue}`)
    this.showConnectionStatus('rejected')
  }

  showConnectionStatus(status) {
    // Optional: Add a visual indicator for connection status
    // Could add a small badge or notification in the UI
    console.log(`[MessagesController] Connection status: ${status}`)
  }

  _received(data) {
    console.log('[MessagesController] Received data:', data.type, data)

    // Handle typing indicators
    if (data.type === "typing") {
      if (data.person_id !== this.currentPersonIdValue) {
        console.log(`[MessagesController] ${data.person_name} is typing`)
        this.addTypingPerson(data.person_id, data.person_name)
      }
      return
    }

    if (data.type === "stop_typing") {
      if (data.person_id !== this.currentPersonIdValue) {
        console.log(`[MessagesController] Person ${data.person_id} stopped typing`)
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
      console.log(`[MessagesController] Message ${data.message_id} updated`)
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
      console.log(`[MessagesController] Message ${data.message_id} deleted`)
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
      console.log(`[MessagesController] Reaction ${data.type} for message ${data.message_id}`)
      if (data.sender_id !== this.currentPersonIdValue) {
        this.updateReactions(data.message_id)
      }
      return
    }

    // Append message from other users (current user's message shown via Turbo Stream)
    if (data.sender_id !== this.currentPersonIdValue) {
      if (data.type === "thread_reply") {
        console.log(`[MessagesController] Received thread reply for parent ${data.parent_message_id}`)
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
      } else if (data.type === "message") {
        console.log(`[MessagesController] Received new message, appending to container`)
        // Handle regular message
        if (this.hasContainerTarget) {
          this.containerTarget.insertAdjacentHTML("beforeend", data.message)
          setTimeout(() => this.scrollToBottom(), 100)
        } else {
          console.warn('[MessagesController] Container target not found, cannot append message')
        }
      }
    } else {
      console.log(`[MessagesController] Ignoring own message (sender: ${data.sender_id}, current: ${this.currentPersonIdValue})`)
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
    if (event.detail.success !== false) {
      if (this.hasInputTarget && this.hasFormTarget) {
        this.inputTarget.value = ''
        this.inputTarget.focus()
      }

      // Clear file upload preview if present
      const fileUploadController = this.application.getControllerForElementAndIdentifier(
        this.element.querySelector('[data-controller*="file-upload"]'),
        'file-upload'
      )
      if (fileUploadController) {
        fileUploadController.clearFiles()
      }

      // Stop typing indicator when message is sent
      this.stopTyping()
      this.isTyping = false
      if (this.typingTimeout) {
        clearTimeout(this.typingTimeout)
        this.typingTimeout = null
      }
    }
  }

  handleSubmit(event) {
    const content = this.inputTarget.value.trim()
    if (!content) {
      event.preventDefault()
      return
    }

    // Let form submit naturally
  }

  handleKeydown(event) {
    // Submit on Cmd+Enter or Ctrl+Enter
    if ((event.metaKey || event.ctrlKey) && event.key === 'Enter') {
      event.preventDefault()
      if (this.hasFormTarget) {
        // Trigger the form's submit event which will handle optimistic UI
        const submitEvent = new Event('submit', { bubbles: true, cancelable: true })
        this.formTarget.dispatchEvent(submitEvent)
      }
    }
  }

  handleInput(event) {
    // Send typing indicator (throttled to avoid excessive server requests)
    if (this.subscription) {
      this.sendTyping()
    }
  }

  sendTyping() {
    // Only send typing event if not already marked as typing (throttle)
    if (!this.isTyping && this.subscription) {
      console.log(`[MessagesController] Sending typing indicator for person ${this.currentPersonIdValue}`)
      this.subscription.perform("typing", { person_id: this.currentPersonIdValue })
      this.isTyping = true
    }

    // Clear any existing timeout
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout)
    }

    // Set timeout to stop typing after 3 seconds of inactivity
    this.typingTimeout = setTimeout(() => {
      this.stopTyping()
      this.isTyping = false
    }, 3000)
  }

  stopTyping() {
    if (this.subscription && this.isTyping) {
      console.log(`[MessagesController] Sending stop typing for person ${this.currentPersonIdValue}`)
      this.subscription.perform("stop_typing", { person_id: this.currentPersonIdValue })
    }
  }

  addTypingPerson(personId, personName) {
    // Clear existing timeout if any (person sent new typing event)
    if (this.typingTimeouts.has(personId)) {
      clearTimeout(this.typingTimeouts.get(personId))
    }

    this.typingPeople.set(personId, personName)
    this.updateTypingIndicator()

    // Auto-remove after 5 seconds
    const timeout = setTimeout(() => {
      this.removeTypingPerson(personId)
    }, 5000)
    this.typingTimeouts.set(personId, timeout)
  }

  removeTypingPerson(personId) {
    // Clear timeout if exists
    if (this.typingTimeouts.has(personId)) {
      clearTimeout(this.typingTimeouts.get(personId))
      this.typingTimeouts.delete(personId)
    }

    this.typingPeople.delete(personId)
    this.updateTypingIndicator()
  }

  updateTypingIndicator() {
    if (!this.hasTypingIndicatorTarget) {
      console.warn('[MessagesController] Typing indicator target not found')
      return
    }

    const typingArray = Array.from(this.typingPeople.entries()).map(([id, name]) => ({ id, name }))

    console.log(`[MessagesController] Updating typing indicator: ${typingArray.length} people typing`)

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
