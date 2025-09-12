import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ["panel"]

  toggle(event) {
    event.stopPropagation()

    if (this.element.classList.contains('active')) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.element.classList.add('active')
    this.showPanel()
  }

  close() {
    if (!this.element.classList.contains('active')) return

    this.element.classList.remove('active')
    this.hidePanel()
  }

  closeOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  // --- Animation Helper Methods ---

  showPanel() {
    this.panelTarget.classList.remove('hidden')
    this.panelTarget.classList.add('opacity-0', 'scale-95')
    requestAnimationFrame(() => {
      this.panelTarget.classList.remove('opacity-0', 'scale-95')
      this.panelTarget.classList.add('opacity-100', 'scale-100')
    })
  }

  hidePanel() {
    this.panelTarget.classList.remove('opacity-100', 'scale-100')
    this.panelTarget.classList.add('opacity-0', 'scale-95')
    setTimeout(() => {
      this.panelTarget.classList.add('hidden')
    }, 100)
  }
}