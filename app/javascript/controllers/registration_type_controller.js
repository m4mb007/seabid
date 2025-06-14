import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="registration-type"
export default class extends Controller {
  static targets = ["seafarerFields", "agentFields", "seafarerRadio", "agentRadio"]

  connect() {
    // Set initial state
    if (this.seafarerRadioTarget.checked || this.agentRadioTarget.checked) {
      this.toggle()
    } else {
      // Default to seafarer if nothing is selected
      this.seafarerRadioTarget.checked = true
      this.toggle()
    }
  }

  toggle() {
    if (this.seafarerRadioTarget.checked) {
      this.seafarerFieldsTarget.classList.remove('hidden')
      this.agentFieldsTarget.classList.add('hidden')
    } else if (this.agentRadioTarget.checked) {
      this.seafarerFieldsTarget.classList.add('hidden')
      this.agentFieldsTarget.classList.remove('hidden')
    }
  }
} 