import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown"]
  static values = {
    channelId: Number
  }

  connect() {
    this.selectedIndex = -1
    this.mentioning = false
    this.mentionStartPos = -1
    this.people = []
  }

  handleInput(event) {
    const input = this.inputTarget
    const cursorPos = input.selectionStart
    const text = input.value

    // Find the last @ before cursor position
    const textBeforeCursor = text.substring(0, cursorPos)
    const lastAtIndex = textBeforeCursor.lastIndexOf('@')

    if (lastAtIndex === -1) {
      this.hideDropdown()
      return
    }

    // Check if there's a space or start of string before the @
    const charBeforeAt = lastAtIndex > 0 ? text[lastAtIndex - 1] : ' '
    if (charBeforeAt !== ' ' && lastAtIndex !== 0) {
      this.hideDropdown()
      return
    }

    // Get the text after @ until cursor
    const queryText = textBeforeCursor.substring(lastAtIndex + 1)

    // If there's a space in the query text, we're not mentioning anymore
    if (queryText.includes(' ')) {
      this.hideDropdown()
      return
    }

    // We're in mention mode
    this.mentioning = true
    this.mentionStartPos = lastAtIndex
    this.fetchPeople(queryText)
  }

  handleKeydown(event) {
    if (!this.mentioning || !this.hasDropdownTarget) return
    if (this.dropdownTarget.classList.contains('hidden')) return

    if (event.key === 'ArrowDown') {
      event.preventDefault()
      this.selectedIndex = Math.min(this.selectedIndex + 1, this.people.length - 1)
      this.updateSelection()
    } else if (event.key === 'ArrowUp') {
      event.preventDefault()
      this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
      this.updateSelection()
    } else if (event.key === 'Enter' || event.key === 'Tab') {
      if (this.selectedIndex >= 0 && this.selectedIndex < this.people.length) {
        event.preventDefault()
        this.selectPerson(this.people[this.selectedIndex])
      }
    } else if (event.key === 'Escape') {
      event.preventDefault()
      this.hideDropdown()
    }
  }

  async fetchPeople(query) {
    try {
      const response = await fetch(`/channels/${this.channelIdValue}/members_autocomplete?query=${encodeURIComponent(query)}`)
      const data = await response.json()
      this.people = data
      this.showDropdown()
    } catch (error) {
      console.error('Error fetching people:', error)
      this.hideDropdown()
    }
  }

  showDropdown() {
    if (this.people.length === 0) {
      this.hideDropdown()
      return
    }

    this.selectedIndex = 0
    const dropdown = this.dropdownTarget
    dropdown.innerHTML = ''

    this.people.forEach((person, index) => {
      const item = document.createElement('div')
      item.className = `px-4 py-2 cursor-pointer ${index === this.selectedIndex ? 'bg-indigo-100' : 'hover:bg-gray-100'}`
      item.textContent = person.name
      item.dataset.index = index
      item.addEventListener('click', () => this.selectPerson(person))
      dropdown.appendChild(item)
    })

    dropdown.classList.remove('hidden')
  }

  hideDropdown() {
    this.mentioning = false
    this.mentionStartPos = -1
    this.selectedIndex = -1
    this.people = []
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.add('hidden')
      this.dropdownTarget.innerHTML = ''
    }
  }

  updateSelection() {
    const items = this.dropdownTarget.querySelectorAll('[data-index]')
    items.forEach((item, index) => {
      if (index === this.selectedIndex) {
        item.classList.add('bg-indigo-100')
        item.classList.remove('hover:bg-gray-100')
      } else {
        item.classList.remove('bg-indigo-100')
        item.classList.add('hover:bg-gray-100')
      }
    })
  }

  selectPerson(person) {
    const input = this.inputTarget
    const text = input.value
    const before = text.substring(0, this.mentionStartPos)
    const after = text.substring(input.selectionStart)

    // Insert the mention with @ and a space after
    input.value = `${before}@${person.name} ${after}`

    // Position cursor after the mention
    const newCursorPos = before.length + person.name.length + 2
    input.setSelectionRange(newCursorPos, newCursorPos)
    input.focus()

    this.hideDropdown()
  }

  disconnect() {
    this.hideDropdown()
  }
}
