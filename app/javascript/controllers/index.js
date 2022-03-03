// Import and register all your controllers from the importmap under controllers/*

import { application } from "./application"

import DsaController from "./dsa_controller"
application.register("dsa", DsaController)
