import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["searchResults", "searchInput"];

  connect() {
    document.addEventListener("click", this.outsideClickListener.bind(this));
  }
  
  disconnect() { 
    
  }

  toggle() {
    if (this.searchResultsTarget.classList.contains("hidden")) {
      this.open();
    } else {
      this.close();
    }
  }

  open() {
    this.searchResultsTarget.classList.remove("hidden");
    //let main = document.querySelector("main");
    //main.classList.add("blur");
    //document.body.classList.add("overflow-hidden");
    //main.classList.add("overflow-hidden");
    //main.classList.remove("overflow-y-auto");
  }

  close() {
    this.searchResultsTarget.classList.add("hidden");
    //let main = document.querySelector("main");
    //main.classList.remove("blur");
    //document.body.classList.remove("overflow-hidden");
    //main.classList.remove("overflow-hidden");
    //main.classList.add("overflow-y-auto")
  }

  outsideClickListener(event) {
    if (!this.element.contains(event.target)) {
      this.close();
    }
  }
}
