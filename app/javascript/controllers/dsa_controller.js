import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  static values = { 
    lastupn: String, 
    url: String, 
    userupn: String 
  }

  setLastUpn() {
    console.log('setLastUpn: ' + this.lastupnValue);
    document.getElementById("unload_recipient_upn").value = this.lastupnValue;
  }

  searchUser() {
    console.log("Modal su url " + this.urlValue);
    const mainModal = document.getElementById('mainModal');
    const bsmainModal = new bootstrap.Modal(mainModal, {});
    mainModal.querySelector(".modal-title").innerHTML = "Ricerca utenti nella Rubrica di Ateneo";
    bsmainModal.show()
    fetch(this.urlValue)
      .then(response => response.text())
      .then(html => mainModal.querySelector(".modal-body").innerHTML = html)
  }

  select_user() {
    console.log("SELECT USER: " + this.userupnValue);
    document.getElementById("unload_recipient_upn").value = this.userupnValue;
    const mainModal = document.getElementById('mainModal');
    const bsmainModal = bootstrap.Modal.getInstance(mainModal);
    bsmainModal.hide()
    console.log("SELECT USER FINE")
  }

  submitNameSurnameSearchUser(e) {
    console.log("submitSearchUser");
    console.log(e);
    e.preventDefault;
  }
};
