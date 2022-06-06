import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    lastupn: String, 
    userupn: String 
  }

  setLastUpn() {
    console.log('dsa#setLastUpn: ' + this.lastupnValue);
    document.getElementById("unload_recipient_upn").value = this.lastupnValue;
  }

  select_user() {
    console.log("dsa#select_user: " + this.userupnValue);
    document.getElementById("unload_recipient_upn").value = this.userupnValue;
  }

  // searchUser() {
  //   console.log("Modal su url " + this.urlValue);
  //   const mainModal = document.getElementById('modal');
  //   const bsmainModal = new bootstrap.Modal(mainModal, {});
  //   bsmainModal.show()
  //   fetch(this.urlValue)
  //     .then(response => response.text())
  //     .then(html => mainModal.querySelector(".modal-body").innerHTML = html)
  // }

  // submitNameSurnameSearchUser(e) {
  //   console.log("submitSearchUser");
  //   console.log(e);
  //   e.preventDefault;
  // }
};
