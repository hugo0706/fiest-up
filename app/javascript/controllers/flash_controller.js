import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["flash"]

  connect() {
    this.showFlashMessages()
  }

  showFlashMessages() {
    this.flashTargets.forEach((flash, index) => {
      setTimeout(() => {
        flash.classList.remove('opacity-0')
        flash.classList.add('opacity-100')
        
        setTimeout(() => {
          flash.classList.remove('opacity-100')
          flash.classList.add('opacity-0')
        }, 3500)
      }, index * 1150)
    })
  }
}