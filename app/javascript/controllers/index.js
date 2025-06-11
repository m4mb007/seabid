// Import and register all your controllers from the importmap under controllers/**/*_controller
import { application } from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import RegistrationTypeController from "./registration_type_controller"

// Eager load all controllers defined in the import map under controllers/**/*_controller
eagerLoadControllersFrom("controllers", application)

// Manually register the registration type controller
application.register("registration-type", RegistrationTypeController)
