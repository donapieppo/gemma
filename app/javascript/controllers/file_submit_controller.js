import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit(event) {
    const input = event.currentTarget

    if (input.files.length === 0 || input.form === null) {
      return
    }

    if (input.form.requestSubmit) {
      input.form.requestSubmit()
    } else {
      input.form.submit()
    }
  }
}
