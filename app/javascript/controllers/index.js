import { application } from "./application"

import DsaController from "./dsa_controller"
application.register("dsa", DsaController)
import FocusController from "./focus"
application.register("focus", FocusController)
import DsaAwesomplete from "./dsa_awesomplete.js"
application.register("dsa-awesomplete", DsaAwesomplete)
import { DmTest, TurboModalController } from "dm_unibo_common"
application.register("turbo-modal", TurboModalController)
