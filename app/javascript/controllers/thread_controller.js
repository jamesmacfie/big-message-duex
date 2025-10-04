import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "messagesList", "parentMessage", "repliesList", "form"]
  static values = {
    messageId: Number,
    channelId: Number
  }

  connect() {
    this.element.classList.add("hidden")
  }

  open(event) {
    event.preventDefault()
    const messageId = event.currentTarget.dataset.messageId
    const channelId = this.channelIdValue
    
    // Fetch thread data
    fetch(`/channels/${channelId}/messages/${messageId}/thread`)
      .then(response => response.text())
      .then(html => {
        this.element.innerHTML = html
        this.element.classList.remove("hidden")
      })
  }

  close(event) {
    event.preventDefault()
    this.element.classList.add("hidden")
    this.element.innerHTML = ""
  }

  submitReply(event) {
    // Form submission is handled by Turbo
    // This method can be used for additional client-side logic if needed
  }
}
