import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "list"]

  connect() {
    console.log("File upload controller connected")
    this.uploading = false
  }

  handleFiles(event) {
    const files = Array.from(this.inputTarget.files)

    if (files.length > 0) {
      this.showPreview()
      this.displayFiles(files)
    } else {
      this.hidePreview()
    }
  }

  displayFiles(files) {
    this.listTarget.innerHTML = ""

    files.forEach((file, index) => {
      const fileItem = document.createElement("div")
      fileItem.className = "flex items-center justify-between py-1 px-2 bg-white rounded border border-gray-200"
      fileItem.dataset.fileIndex = index

      const fileInfo = document.createElement("div")
      fileInfo.className = "flex items-center space-x-2 flex-1"

      const fileIcon = this.getFileIcon(file.type)
      fileInfo.innerHTML = `
        <svg class="w-4 h-4 text-gray-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          ${fileIcon}
        </svg>
        <div class="flex-1 min-w-0">
          <div class="flex items-center space-x-2">
            <span class="text-sm text-gray-700 truncate">${file.name}</span>
            <span class="text-xs text-gray-500 flex-shrink-0">${this.formatFileSize(file.size)}</span>
          </div>
          <div class="upload-progress hidden mt-1">
            <div class="upload-progress-bar" style="width: 0%"></div>
          </div>
        </div>
      `

      const removeButton = document.createElement("button")
      removeButton.type = "button"
      removeButton.className = "text-red-600 hover:text-red-800 flex-shrink-0 ml-2"
      removeButton.innerHTML = `
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
        </svg>
      `
      removeButton.addEventListener("click", () => this.removeFile(index))

      fileItem.appendChild(fileInfo)
      fileItem.appendChild(removeButton)
      this.listTarget.appendChild(fileItem)
    })
  }

  startUpload() {
    this.uploading = true
    // Show progress bars for all files
    this.listTarget.querySelectorAll(".upload-progress").forEach(progressBar => {
      progressBar.classList.remove("hidden")
    })
    // Simulate upload progress (in real implementation, this would track actual upload)
    this.simulateProgress()
  }

  simulateProgress() {
    let progress = 0
    const interval = setInterval(() => {
      progress += 10
      this.listTarget.querySelectorAll(".upload-progress-bar").forEach(bar => {
        bar.style.width = `${Math.min(progress, 100)}%`
      })
      if (progress >= 100) {
        clearInterval(interval)
      }
    }, 100)
  }

  removeFile(index) {
    const dt = new DataTransfer()
    const files = Array.from(this.inputTarget.files)

    files.forEach((file, i) => {
      if (i !== index) {
        dt.items.add(file)
      }
    })

    this.inputTarget.files = dt.files

    if (this.inputTarget.files.length === 0) {
      this.hidePreview()
    } else {
      this.displayFiles(Array.from(this.inputTarget.files))
    }
  }

  clearFiles() {
    this.inputTarget.value = ""
    this.hidePreview()
  }

  showPreview() {
    this.previewTarget.classList.remove("hidden")
  }

  hidePreview() {
    this.previewTarget.classList.add("hidden")
    this.listTarget.innerHTML = ""
  }

  getFileIcon(mimeType) {
    if (mimeType.startsWith("image/")) {
      return '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>'
    } else if (mimeType.startsWith("video/")) {
      return '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"></path>'
    } else {
      return '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path>'
    }
  }

  formatFileSize(bytes) {
    if (bytes < 1024) return bytes + " B"
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
    return (bytes / (1024 * 1024)).toFixed(1) + " MB"
  }
}
