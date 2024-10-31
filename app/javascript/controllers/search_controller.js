import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["searchResults", "searchInput"];

  connect() {
  }
  
  disconnect() {
    this.removeOutsideClickListener();
  }
  
  addToQueue(event) {
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
    });
    
    this.close();
  }
  
  removeFromQueue(event) {
    const song = event.currentTarget;
    const removeFromQueueUrl = song.getAttribute('data-remove-from-queue-url');

    fetch(removeFromQueueUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
    });
  }
  
  checkInput() {
    const inputValue = this.searchInputTarget.value.trim();

    clearTimeout(this.timeout);
    
    if (inputValue.length > 2) {
      this.timeout = setTimeout(() => {
        this.search(inputValue);
      }, 300);
    }
  }
  
  search(query) {
    const searchUrl = this.element.getAttribute("data-search-url");
    fetch(searchUrl + '?query=' + encodeURIComponent(query))
      .then(response => response.text())
      .then(html => {
        this.searchResultsTarget.innerHTML = html;
        this.open(); // Ensure search results open after loading
      });
  }

  open() {
    this.searchResultsTarget.classList.remove("hidden");
    this.addOutsideClickListener();
  }

  close() {
    this.searchResultsTarget.classList.add("hidden");
    this.removeOutsideClickListener();
  }

  addOutsideClickListener() {
    if (!this.outsideClickListener) {
      this.outsideClickListener = (event) => {
        if (!this.element.contains(event.target)) {
          this.close();
        }
      };
      document.addEventListener("click", this.outsideClickListener);
    }
  }

  removeOutsideClickListener() {
    if (this.outsideClickListener) {
      document.removeEventListener("click", this.outsideClickListener);
      this.outsideClickListener = null;
    }
  }
};
