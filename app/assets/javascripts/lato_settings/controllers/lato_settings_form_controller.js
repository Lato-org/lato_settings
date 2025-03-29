import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "inputTypology",
    "linkTypologySelected"
  ]
  
  connect() {
    this.onInputTypologyChange = this.onInputTypologyChange.bind(this)

    if (this.hasInputTypologyTarget && this.hasLinkTypologySelectedTarget) {
      this.inputTypologyTarget.addEventListener("change", this.onInputTypologyChange)
    }
  }

  onInputTypologyChange(event) {
    if (!this.hasInputTypologyTarget) return
    if (!this.hasLinkTypologySelectedTarget) return
    if (!event.target.value) return
    
    this.linkTypologySelectedTarget.href = this.linkTypologySelectedTarget.href.replace(/typology=[^&]*/, `typology=${event.target.value}`)
    this.linkTypologySelectedTarget.click()
  }
}