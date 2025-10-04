import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["panel"]
  static values = {
    messageId: Number,
    channelId: Number
  }

  connect() {
    this.currentMessageId = null
    this.threadPanel = document.getElementById('thread-panel')

    // Subscribe to thread updates for auto-scroll
    this.setupThreadSubscription()
  }

  disconnect() {
    if (this.threadObserver) {
      this.threadObserver.disconnect()
    }
  }

  setupThreadSubscription() {
    // Set up a MutationObserver to detect new replies being added
    this.threadObserver = new MutationObserver((mutations) => {
      // Check if we should auto-scroll (only if currently scrolled near bottom)
      const repliesContainer = this.element.querySelector('.overflow-y-auto')
      if (repliesContainer && this.shouldAutoScroll(repliesContainer)) {
        setTimeout(() => this.scrollThreadToBottom(), 100)
      }
    })
  }

  open(event) {
    event.preventDefault()

    // Close any previously open thread panel
    this.close(new Event('click'))

    const messageId = event.currentTarget.dataset.messageId
    const channelId = this.channelIdValue
    this.currentMessageId = messageId

    // Fetch thread data
    fetch(`/channels/${channelId}/messages/${messageId}/thread`)
      .then(response => response.text())
      .then(html => {
        this.threadPanel.innerHTML = html
        this.threadPanel.classList.remove("hidden")

        // Scroll to bottom after opening
        setTimeout(() => this.scrollThreadToBottom(), 100)

        // Start observing for new replies
        const repliesContainer = this.threadPanel.querySelector('.overflow-y-auto')
        if (repliesContainer && this.threadObserver) {
          this.threadObserver.observe(repliesContainer, {
            childList: true,
            subtree: true
          })
        }
      })
  }

  close(event) {
    if (event) {
      event.preventDefault()
    }

    // Stop observing
    if (this.threadObserver) {
      this.threadObserver.disconnect()
      this.setupThreadSubscription() // Reset for next use
    }

    this.threadPanel.classList.add("hidden")
    this.threadPanel.innerHTML = ""
    this.currentMessageId = null
  }

  shouldAutoScroll(container) {
    // Auto-scroll if user is within 100px of the bottom
    const threshold = 100
    return (container.scrollHeight - container.scrollTop - container.clientHeight) < threshold
  }

  scrollThreadToBottom() {
    const repliesContainer = this.threadPanel.querySelector('.overflow-y-auto')
    if (repliesContainer) {
      repliesContainer.scrollTop = repliesContainer.scrollHeight
    }
  }

  submitReply(event) {
    // Form submission is handled by Turbo
    // Auto-scroll after reply submission
    setTimeout(() => this.scrollThreadToBottom(), 100)
  }
}
