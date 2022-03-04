import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  static values = { 
    lastupn: String, 
    url: String, 
    userupn: String 
  }

  setLastUpn() {
    document.getElementById("unload_recipient_upn").value = this.lastupnValue;
  }

  searchUser() {
    console.log("RICERCA: " + this.urlValue);
    const mainModal = document.getElementById('mainModal');
    const bsmainModal = new bootstrap.Modal(mainModal, {});
    //$(".modal-body").html("<%= j render(template: 'dsausers/popup_find.html.erb') %>");
    mainModal.querySelector(".modal-title").innerHTML = "Ricerca utenti nella Rubrica di Ateneo";
    mainModal.querySelector(".modal-body").innerHTML = "Ricerca utenti nella Rubrica di Ateneo";
    fetch(this.urlValue)
      .then(response => response.text())
      .then(html => mainModal.querySelector(".modal-body").innerHTML = html)
    bsmainModal.show()
  }

  select_user() {
    console.log("SELECT USER: " + this.userupnValue);
    document.getElementById("unload_recipient_upn").value = this.userupnValue;
    const mainModal = document.getElementById('mainModal');
    const bsmainModal = bootstrap.Modal.getInstance(mainModal);
    bsmainModal.hide()
    console.log("SELECT USER FINE")
  }
};

