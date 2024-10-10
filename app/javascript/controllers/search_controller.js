import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["searchResults", "searchInput"];

  connect() {
    document.addEventListener("click", this.outsideClickListener.bind(this));
  }
  
  disconnect() { 
    
  }
  
  
  checkInput() {
    const inputValue = this.searchInputTarget.value.trim()

    clearTimeout(this.timeout)
    
    if (inputValue.length > 2) {
      this.timeout = setTimeout(() => {
        this.search(inputValue)
      }, 300)
    }
  }
  
  search(query) {
    const searchUrl = this.element.getAttribute("data-search-url")
    fetch(searchUrl + '?query=' + encodeURIComponent(query))
    .then(response => response.text())
    .then(html => {
      document.getElementById("searchResults").innerHTML = html;
    });
  }

  open() {
    this.searchResultsTarget.classList.remove("hidden");
  }

  close() {
    this.searchResultsTarget.classList.add("hidden");
  }

  outsideClickListener(event) {
    if (!this.element.contains(event.target)) {
      this.close();
    }
  }
}
