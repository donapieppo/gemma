import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { lastupn: String }

  setLastUpn() {
    document.getElementById("unload_recipient_upn").value = this.lastupnValue;
  }
  searchUser() {
    console.log("RICERCA");
  }
};

