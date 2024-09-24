import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["code", "codeError"];

  join() {
    const partyCode = this.codeTarget.value.trim();
    
    if (partyCode.length !== 6) {
      this.codeTarget.classList.add("ring-red-500", "border-red-500");

      this.codeErrorTarget.textContent = "The party codes are 6 characters long";
      this.codeErrorTarget.classList.remove("hidden");
      return;
    }
    
    window.location.href = `/party/join/${partyCode}`;
  }
}