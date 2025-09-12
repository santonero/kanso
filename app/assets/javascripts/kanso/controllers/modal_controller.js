import { Controller } from "@hotwired/stimulus";
import { enter, leave } from "transition";

export default class extends Controller {
  static targets = ["container", "backdrop", "panel"];

  connect() {
    this.clickedOnBackdrop = false;
  }

  backdropMousedown(event) {
    if (event.target === this.backdropTarget) {
      this.clickedOnBackdrop = true;
    }
  }

  backdropMouseup(event) {
    if (this.clickedOnBackdrop && event.target === this.backdropTarget) {
      this.close(event);
    }
    this.clickedOnBackdrop = false;
  }

  open(event) {
    event.preventDefault();

    this.triggerElement = event.currentTarget;
    this.element.classList.add("active");
    this.containerTarget.classList.remove("hidden");

    enter(this.backdropTarget);
    enter(this.panelTarget);
  }

  close(event) {
    if (!this.element.classList.contains("active")) return;
    event.preventDefault();

    Promise.all([
      leave(this.panelTarget),
      leave(this.backdropTarget)
    ]).then( () => {
      this.element.classList.remove("active");
      this.containerTarget.classList.add("hidden");
      this.triggerElement?.focus();
    });
  }
}