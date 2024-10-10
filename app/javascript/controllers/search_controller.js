import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["searchResults", "searchInput"];

  connect() {
    document.addEventListener("click", this.outsideClickListener.bind(this));
  }
  
  disconnect() { 
    
  }
  
  addToQueue(event){
    const song = event.currentTarget;
    const addToQueueUrl = song.getAttribute('data-add-to-queue-url');
    
    fetch(addToQueueUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
    })
    
    this.close();
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
      this.searchResultsTarget.innerHTML = html;
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
