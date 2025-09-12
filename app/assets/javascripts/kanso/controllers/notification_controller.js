import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    duration: { type: Number, default: 5000 }
  }

  connect() {
    this.animateIn();

    this.timeout = setTimeout(() => {
      this.close();
    }, this.durationValue);
  }

  animateIn() {
    requestAnimationFrame(() => {
      this.element.classList.remove('opacity-0', 'translate-x-full');
    });
  }

  close() {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }

    this.animateOut();
  }

  animateOut() {
    this.element.classList.add('opacity-0', 'transform', 'scale-95');

    this.element.addEventListener('transitionend', () => {
      this.element.remove();
    }, { once: true });
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
  }
}