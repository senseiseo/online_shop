import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["links", "button"]

  toggle() {
    this.linksTarget.classList.toggle("hidden")
    this.buttonTarget.setAttribute("aria-expanded", this.buttonTarget.getAttribute("aria-expanded") !== "true")
  }
}
