import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "dropdown"]
  static values = {
    url: { type: String, default: "/search" },
    debounce: { type: Number, default: 300 }
  }

  connect() {
    this.timeout = null
    this.currentIndex = -1

    // Close dropdown when clicking outside
    this.clickOutsideHandler = this.handleClickOutside.bind(this)
    document.addEventListener('click', this.clickOutsideHandler)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
    document.removeEventListener('click', this.clickOutsideHandler)
  }

  search(event) {
    const query = this.inputTarget.value.trim()

    // Clear existing timeout
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    // If query is empty, hide results
    if (query === '') {
      this.hideResults()
      return
    }

    // Debounce the search
    this.timeout = setTimeout(() => {
      this.performSearch(query)
    }, this.debounceValue)
  }

  async performSearch(query) {
    try {
      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, {
        headers: {
          'Accept': 'text/html',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (response.ok) {
        const html = await response.text()
        this.resultsTarget.innerHTML = html
        this.showResults()
        this.currentIndex = -1
      }
    } catch (error) {
      console.error('Search error:', error)
    }
  }

  handleKeydown(event) {
    const results = this.getResultElements()

    if (!this.dropdownTarget.classList.contains('hidden') && results.length > 0) {
      switch (event.key) {
        case 'ArrowDown':
          event.preventDefault()
          this.currentIndex = Math.min(this.currentIndex + 1, results.length - 1)
          this.highlightResult(results)
          break
        case 'ArrowUp':
          event.preventDefault()
          this.currentIndex = Math.max(this.currentIndex - 1, -1)
          this.highlightResult(results)
          break
        case 'Enter':
          event.preventDefault()
          if (this.currentIndex >= 0 && results[this.currentIndex]) {
            results[this.currentIndex].click()
          }
          break
        case 'Escape':
          event.preventDefault()
          this.hideResults()
          this.inputTarget.blur()
          break
      }
    }
  }

  getResultElements() {
    return Array.from(this.resultsTarget.querySelectorAll('a'))
  }

  highlightResult(results) {
    // Remove previous highlight
    results.forEach(result => {
      result.classList.remove('bg-indigo-800')
    })

    // Add highlight to current
    if (this.currentIndex >= 0 && results[this.currentIndex]) {
      results[this.currentIndex].classList.add('bg-indigo-800')
      results[this.currentIndex].scrollIntoView({ block: 'nearest' })
    }
  }

  showResults() {
    this.dropdownTarget.classList.remove('hidden')
  }

  hideResults() {
    this.dropdownTarget.classList.add('hidden')
    this.currentIndex = -1
  }

  selectResult() {
    this.hideResults()
    this.inputTarget.value = ''
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideResults()
    }
  }

  focus() {
    this.inputTarget.focus()
  }

  clear() {
    this.inputTarget.value = ''
    this.hideResults()
  }
}
