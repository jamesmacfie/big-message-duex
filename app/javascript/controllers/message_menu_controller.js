import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "menuContainer", "editForm"]

  toggleMenu() {
    this.menuTarget.classList.toggle("hidden")
  }

  startEdit(event) {
    event.preventDefault()

    // Hide menu
    this.menuTarget.classList.add("hidden")

    // Hide content and show edit form
    const messageId = this.element.dataset.messageId
    const contentDiv = document.getElementById(`message-content-${messageId}`)
    const editDiv = document.getElementById(`message-edit-${messageId}`)

    if (contentDiv && editDiv) {
      contentDiv.classList.add("hidden")
      editDiv.classList.remove("hidden")

      // Focus the textarea
      const textarea = editDiv.querySelector("textarea")
      if (textarea) {
        textarea.focus()
        textarea.setSelectionRange(textarea.value.length, textarea.value.length)
      }
    }
  }

  cancelEdit(event) {
    event.preventDefault()

    const messageId = this.element.dataset.messageId
    const contentDiv = document.getElementById(`message-content-${messageId}`)
    const editDiv = document.getElementById(`message-edit-${messageId}`)

    if (contentDiv && editDiv) {
      contentDiv.classList.remove("hidden")
      editDiv.classList.add("hidden")
    }
  }

  // Close menu when clicking outside
  connect() {
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.boundHandleClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.boundHandleClickOutside)
  }

  handleClickOutside(event) {
    if (this.hasMenuTarget && !this.menuTarget.classList.contains("hidden")) {
      if (!this.menuContainerTarget.contains(event.target)) {
        this.menuTarget.classList.add("hidden")
      }
    }
  }
}
