import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["container", "form", "input", "typingIndicator", "clientTempId"]
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

    // Track typing people (Map: personId -> personName)
    this.typingPeople = new Map()
    this.typingTimeouts = new Map()
    this.typingTimeout = null
    this.isTyping = false
    this.optimisticMessageCounter = 0
    this.optimisticMessageMap = new Map()
    this.isSubmitting = false

    if (this.hasClientTempIdTarget) {
      this.clientTempIdTarget.value = ''
    }
  }

  disconnect() {
    // Stop typing indicator before unsubscribing
    this.stopTyping()

    // Clear all timeouts
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout)
      this.typingTimeout = null
    }
    if (this.typingTimeouts) {
      this.typingTimeouts.forEach(timeout => clearTimeout(timeout))
      this.typingTimeouts.clear()
    }

    this.optimisticMessageMap = new Map()

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

    if (data.type === "message" && data.sender_id === this.currentPersonIdValue) {
      this.removeOptimisticMessage(data.client_temp_id)
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
    const tempId = event.detail?.formSubmission?.formData?.get('client_temp_id') || null

    if (event.detail.success !== false) {
      this.removeOptimisticMessage(tempId)

      if (this.hasClientTempIdTarget) {
        this.clientTempIdTarget.value = ''
      }

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
    } else {
      this.removeOptimisticMessage(tempId)
      if (this.hasClientTempIdTarget) {
        this.clientTempIdTarget.value = ''
      }
    }
  }

  handleSubmit(event) {
    // Prevent infinite loop - if we're already submitting, let it through
    if (this.isSubmitting) {
      this.isSubmitting = false
      return
    }

    // Prevent default to set client_temp_id before form data is captured
    event.preventDefault()

    // Don't show optimistic message if there are file attachments
    // (they need to be uploaded first)
    const fileInput = this.formTarget.querySelector('input[type="file"]')
    if (fileInput && fileInput.files.length > 0) {
      // Just submit without optimistic UI
      this.isSubmitting = true
      event.target.requestSubmit()
      return
    }

    const content = this.inputTarget.value.trim()
    if (!content) {
      return
    }

    // Create optimistic message and set client_temp_id BEFORE submitting
    this.createAndShowOptimisticMessage(content)

    // Now submit the form with client_temp_id set
    this.isSubmitting = true
    event.target.requestSubmit()
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

  createAndShowOptimisticMessage(content) {
    // Only create optimistic UI if we have a container (not on GIF preview page, etc.)
    if (!this.hasContainerTarget) {
      return
    }

    // Create optimistic message immediately
    const optimisticId = `optimistic-${this.optimisticMessageCounter++}`
    const tempId = this.generateTempId()
    const messageHtml = this.createOptimisticMessage(content, optimisticId)

    // Add to DOM
    this.containerTarget.insertAdjacentHTML("beforeend", messageHtml)
    this.scrollToBottom()

    // Track optimistic message so we can remove it later
    this.optimisticMessageMap.set(tempId, optimisticId)

    if (this.hasClientTempIdTarget) {
      this.clientTempIdTarget.value = tempId
    }
  }

  createOptimisticMessage(content, optimisticId) {
    // Get current user info from the page
    const userNameElement = document.querySelector('[data-messages-current-person-id-value]')
    const userName = userNameElement?.closest('[data-controller~="messages"]')?.querySelector('.text-sm')?.textContent || 'You'

    const now = new Date()
    const timeString = now.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })

    // Escape HTML in content
    const escapedContent = content.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')

    return `
      <div class="flex items-start space-x-3 group opacity-60" id="${optimisticId}" data-optimistic="true">
        <div class="flex-shrink-0">
          <div class="h-10 w-10 rounded bg-indigo-600 flex items-center justify-center">
            <span class="text-sm font-medium text-white">${userName[0]?.toUpperCase() || 'U'}</span>
          </div>
        </div>
        <div class="flex-1 min-w-0">
          <div class="flex items-baseline space-x-2">
            <span class="text-sm font-semibold text-gray-900">${userName}</span>
            <span class="text-xs text-gray-500">${timeString}</span>
            <span class="text-xs text-gray-400 italic">Sending...</span>
          </div>
          <div class="mt-1 text-sm text-gray-700">
            <p>${escapedContent}</p>
          </div>
        </div>
      </div>
    `
  }

  handleInput(event) {
    // Send typing indicator (throttled to avoid excessive server requests)
    if (this.subscription) {
      this.sendTyping()
    }
  }

  sendTyping() {
    // Only send typing event if not already marked as typing (throttle)
    if (!this.isTyping) {
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
    if (this.subscription) {
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
    if (!this.hasTypingIndicatorTarget) return

    const typingArray = Array.from(this.typingPeople.entries()).map(([id, name]) => ({ id, name }))

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

  generateTempId() {
    if (window.crypto && typeof window.crypto.randomUUID === 'function') {
      return window.crypto.randomUUID()
    }

    return `temp-${Date.now()}-${Math.random().toString(16).slice(2)}`
  }

  removeOptimisticMessage(tempId = null) {
    let optimisticId = null

    if (tempId && this.optimisticMessageMap.has(tempId)) {
      optimisticId = this.optimisticMessageMap.get(tempId)
      this.optimisticMessageMap.delete(tempId)
    } else if (!tempId) {
      return
    } else {
      // tempId was provided but we no longer have a matching optimistic entry
      return
    }

    if (!optimisticId) return

    const optimisticElement = document.getElementById(optimisticId)
    if (optimisticElement) {
      optimisticElement.remove()
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
