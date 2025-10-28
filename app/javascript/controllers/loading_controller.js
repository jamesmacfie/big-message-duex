import { Controller } from "@hotwired/stimulus"

// Handles loading states for forms and buttons
// Usage: data-controller="loading"
//        data-action="submit->loading#show"
export default class extends Controller {
  static targets = ["spinner", "text", "button"]

  show() {
    // Show spinner if present
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.remove("hidden")
    }

    // Hide text if present
    if (this.hasTextTarget) {
      this.textTarget.classList.add("hidden")
    }

    // Disable button if present
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = true
      this.buttonTarget.classList.add("opacity-50", "cursor-not-allowed")
    }

    // Disable all buttons in the element
    this.element.querySelectorAll("button, input[type='submit']").forEach(btn => {
      btn.disabled = true
      btn.classList.add("opacity-50", "cursor-not-allowed")
    })
  }

  hide() {
    // Hide spinner if present
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.add("hidden")
    }

    // Show text if present
    if (this.hasTextTarget) {
      this.textTarget.classList.remove("hidden")
    }

    // Enable button if present
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = false
      this.buttonTarget.classList.remove("opacity-50", "cursor-not-allowed")
    }

    // Enable all buttons in the element
    this.element.querySelectorAll("button, input[type='submit']").forEach(btn => {
      btn.disabled = false
      btn.classList.remove("opacity-50", "cursor-not-allowed")
    })
  }
}
