import { Controller } from "@hotwired/stimulus"
import Awesomplete from "awesomplete"

export default class extends Controller {
        static values = { 
                users: Array
        }

        // NON METTERE direttamente dsa-awesomplete in input, esplode.
        // Aggiunere
        // <%= content_tag :div, data: { controller: "dsa-awesomplete", dsa_awesomplete_users_value: @cache_users_json } do %>
        connect() {
                new Awesomplete(this.element.querySelector('input'), {list: this.usersValue, minChars: 3});
        }
};
