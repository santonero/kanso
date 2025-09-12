import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static target = [ "errorField", "errorMessage" ]

  errorFieldTargetConnected(element) {
    if (document.activeElement === document.body || document.activeElement === this.element) {
      element.focus();
    }
  }

  errorMessageTargetConnected(element) {
    requestAnimationFrame(() => {
      element.classList.remove("opacity-0", "-translate-y-2");
    });
  }
}