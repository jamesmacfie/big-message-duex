import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["gif", "form", "urlField", "titleField"]

  connect() {
    this.currentIndex = 0
    this.updateFormFields()
  }

  shuffle() {
    // Hide current GIF
    this.gifTargets[this.currentIndex].classList.add("hidden")

    // Move to next GIF (loop back to start if at end)
    this.currentIndex = (this.currentIndex + 1) % this.gifTargets.length

    // Show next GIF
    this.gifTargets[this.currentIndex].classList.remove("hidden")

    // Update form fields
    this.updateFormFields()
  }

  updateFormFields() {
    const currentGif = this.gifTargets[this.currentIndex]
    this.urlFieldTarget.value = currentGif.dataset.gifUrl
    this.titleFieldTarget.value = currentGif.dataset.gifTitle
  }
}
