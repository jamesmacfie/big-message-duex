import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "backdrop"]

  connect() {
    // Close sidebar when clicking a channel/DM link on mobile
    this.element.addEventListener('click', (e) => {
      const link = e.target.closest('a[href^="/channels"]')
      if (link && window.innerWidth < 768) {
        this.close()
      }
    })
  }

  toggle() {
    if (this.sidebarTarget.classList.contains('-translate-x-full')) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.sidebarTarget.classList.remove('-translate-x-full')
    this.backdropTarget.classList.remove('hidden')
    document.body.style.overflow = 'hidden'
  }

  close() {
    this.sidebarTarget.classList.add('-translate-x-full')
    this.backdropTarget.classList.add('hidden')
    document.body.style.overflow = ''
  }
}
