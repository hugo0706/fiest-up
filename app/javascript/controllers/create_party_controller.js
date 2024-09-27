import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["name", "nameError"];

  validate() {
    const name = this.nameTarget.value.trim();

    if (name.length > 15 || name.length < 1) {
      this.nameTarget.classList.add("ring-red-500", "border-red-500");

      this.nameErrorTarget.textContent =
        "Party name must be 1-15 characters long";
      this.nameErrorTarget.classList.remove("hidden");
      return;
    }
  }
}
