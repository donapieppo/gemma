import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "item"]

  connect() {
    this.toggle()
  }

  toggle() {
    if (!this.hasSourceTarget) return
    const checked = this.sourceTarget.checked

    this.itemTargets.forEach((element) => {
      element.style.display = checked ? "none" : ""

      if (checked) {
        element.querySelectorAll("input").forEach((input) => {
          input.checked = false
        })
      }
    })
  }
}

