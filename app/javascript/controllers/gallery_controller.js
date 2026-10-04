import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image"]

  show({ params: { index } }) {
    this.imageTargets.forEach((image, position) => image.classList.toggle("hidden", position !== index))
  }
}
