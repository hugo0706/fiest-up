import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["code", "codeError", "name", "nameError"];
  static values = {
    partyShowUrl: String,
    partyCode: String,
    temporalSessionCreate: String,
  };

  join() {
    const partyCode = this.codeTarget.value.trim();

    if (partyCode.length !== 6) {
      this.codeTarget.classList.add("ring-red-500", "border-red-500");

      this.codeErrorTarget.textContent =
        "The party codes are 6 characters long";
      this.codeErrorTarget.classList.remove("hidden");
      return;
    }

    window.location.href = `/party/join/${partyCode}`;
  }

  non_oauth_join() {
    const name = this.nameTarget.value.trim();

    if (name.length > 13 || name.length == 0 ) {
      this.nameTarget.classList.add("ring-red-500", "border-red-500");

      this.nameErrorTarget.textContent =
        "Your name has to contain from 1 to 13 letters";
      this.nameErrorTarget.classList.remove("hidden");
      return;
    }

    fetch(this.temporalSessionCreateValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
      body: JSON.stringify({ name: name, code: this.partyCodeValue }),
    })
    .then((response) => {
      if (response.status === 201) {
        return;
      } else {
        throw new Error("Failed to join the party.");
      }
    })
    .then((data) => {
      window.location.href = this.partyShowUrlValue;
    })
    .catch((error) => {
      alert("Error: " + error.message);
    });
  }
}
