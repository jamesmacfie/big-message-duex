import { Controller } from "@hotwired/stimulus"

// Toast notification controller
// Usage: data-controller="toast" data-toast-type-value="success|error|info"
export default class extends Controller {
  static values = {
    type: String,
    duration: { type: Number, default: 5000 },
    autoDismiss: { type: Boolean, default: true }
  }

  connect() {
    this.show()

    if (this.autoDismissValue) {
      this.timeout = setTimeout(() => {
        this.dismiss()
      }, this.durationValue)
    }
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  show() {
    // Slide in animation
    requestAnimationFrame(() => {
      this.element.classList.remove("translate-x-full", "opacity-0")
      this.element.classList.add("translate-x-0", "opacity-100")
    })
  }

  dismiss() {
    // Slide out animation
    this.element.classList.remove("translate-x-0", "opacity-100")
    this.element.classList.add("translate-x-full", "opacity-0")

    // Remove from DOM after animation
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }

  // Static method to create and show a toast
  static show(message, type = "info", duration = 5000) {
    const toast = document.createElement("div")
    toast.setAttribute("data-controller", "toast")
    toast.setAttribute("data-toast-type-value", type)
    toast.setAttribute("data-toast-duration-value", duration)
    toast.className = this.getToastClasses(type)
    toast.innerHTML = this.getToastHTML(message, type)

    const container = this.getOrCreateContainer()
    container.appendChild(toast)
  }

  static getToastClasses(type) {
    const baseClasses = "fixed top-4 right-4 z-50 max-w-md shadow-lg rounded-lg p-4 transform transition-all duration-300 translate-x-full opacity-0"
    const typeClasses = {
      success: "bg-green-50 border-l-4 border-green-400",
      error: "bg-red-50 border-l-4 border-red-400",
      info: "bg-blue-50 border-l-4 border-blue-400",
      warning: "bg-yellow-50 border-l-4 border-yellow-400"
    }
    return `${baseClasses} ${typeClasses[type] || typeClasses.info}`
  }

  static getToastHTML(message, type) {
    const icons = {
      success: `<svg class="h-5 w-5 text-green-400" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
      </svg>`,
      error: `<svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
      </svg>`,
      info: `<svg class="h-5 w-5 text-blue-400" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
      </svg>`,
      warning: `<svg class="h-5 w-5 text-yellow-400" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
      </svg>`
    }

    const colors = {
      success: "text-green-700",
      error: "text-red-700",
      info: "text-blue-700",
      warning: "text-yellow-700"
    }

    return `
      <div class="flex">
        <div class="flex-shrink-0">
          ${icons[type] || icons.info}
        </div>
        <div class="ml-3 flex-1">
          <p class="text-sm ${colors[type] || colors.info}">${message}</p>
        </div>
        <div class="ml-4 flex-shrink-0">
          <button type="button" data-action="click->toast#dismiss" class="${colors[type] || colors.info} hover:opacity-75">
            <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </button>
        </div>
      </div>
    `
  }

  static getOrCreateContainer() {
    let container = document.getElementById("toast-container")
    if (!container) {
      container = document.createElement("div")
      container.id = "toast-container"
      container.className = "fixed top-0 right-0 p-4 space-y-4 z-50"
      document.body.appendChild(container)
    }
    return container
  }
}

// Export for global use
window.Toast = {
  success: (message, duration) => ToastController.show(message, "success", duration),
  error: (message, duration) => ToastController.show(message, "error", duration),
  info: (message, duration) => ToastController.show(message, "info", duration),
  warning: (message, duration) => ToastController.show(message, "warning", duration)
}
