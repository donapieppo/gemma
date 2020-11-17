// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

require("typeahead.js")
require("popper.js")

import 'bootstrap';

window.$ = $;

// require('packs/gemma');

import '../../stylesheets/application.scss';

const images = require.context('../images', true)
const imagePath = (name) => images(name, true)
