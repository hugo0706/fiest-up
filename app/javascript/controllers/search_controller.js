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
    .then(response => response.json())
    .then(data => {
      this.show_results(data)
    })
    .catch(error => {
    
    })
  }
  
  show_results(data) {
    const searchResults = this.searchResultsTarget;
    searchResults.innerHTML = '';
    
    data.forEach(item => {
      const resultDiv = document.createElement('div');
      resultDiv.classList.add('flex', 'items-center', 'justify-between', 'p-1', 'gap-3', 'h-14');

      const innerDiv = document.createElement('div');
      innerDiv.classList.add('flex', 'items-center', 'gap-2', 'flex-grow', 'min-w-0');

      const img = document.createElement('img');
      img.src = item.image;
      img.classList.add('w-12', 'h-12');

      const textWrapper = document.createElement('div');
      textWrapper.classList.add('overflow-hidden', 'text-ellipsis', 'whitespace-nowrap');

      const nameP = document.createElement('p');
      nameP.textContent = item.name;
      nameP.classList.add('font-semibold', 'text-sm', 'truncate'); 

      const artistsP = document.createElement('p');
      artistsP.textContent = item.artists.join(', ');
      artistsP.classList.add('font-semibold', 'text-gray-500', 'text-xs', 'truncate');
  
      textWrapper.appendChild(nameP);
      textWrapper.appendChild(artistsP);
  

      innerDiv.appendChild(img);
      innerDiv.appendChild(textWrapper);
  

      const plusSignP = document.createElement('p');
      plusSignP.textContent = '+';
      plusSignP.classList.add('font-bold', 'text-3xl', 'flex-shrink-0');
  

      resultDiv.appendChild(innerDiv);
      resultDiv.appendChild(plusSignP);
  

      const hr = document.createElement('hr');
      hr.classList.add('border-t', 'border-spotify-gray-highlight', 'opacity-30', 'my-1');
  

      searchResults.appendChild(resultDiv);
      searchResults.appendChild(hr);
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
