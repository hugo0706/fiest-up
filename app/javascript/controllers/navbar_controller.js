import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["content", "dropdownButton"];

  connect() {
    document.addEventListener("click", this.outsideClickListener.bind(this));
  }
  
  disconnect() { 
    
  }

  closeOnBigScreen() {
    if (window.innerWidth > 768) {
      this.close();
    }
  }

  toggle() {
    if (this.contentTarget.classList.contains("hidden")) {
      this.open();
    } else {
      this.close();
    }
  }

  open() {
    this.contentTarget.classList.remove("hidden");
    let main = document.querySelector("main");
    main.classList.add("blur");
    document.body.classList.add("overflow-hidden");
    main.classList.add("overflow-hidden");
    main.classList.remove("overflow-y-auto");
  }

  close() {
    this.contentTarget.classList.add("hidden");
    let main = document.querySelector("main");
    main.classList.remove("blur");
    document.body.classList.remove("overflow-hidden");
    main.classList.remove("overflow-hidden");
    main.classList.add("overflow-y-auto")
  }

  outsideClickListener(event) {
    if (!this.element.contains(event.target)) {
      this.close();
    }
  }
}
