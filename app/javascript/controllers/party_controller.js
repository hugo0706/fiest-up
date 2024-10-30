import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
   static targets = ["input","copyButton","copyButtonText", "startButton","spotifyError", "spinner"]

  copy(event) {
    const button = event.currentTarget;
    const inviteUrl = button.getAttribute('data-invite-url');

    navigator.clipboard.writeText(inviteUrl)
    .then(() => {
      this.copyButtonTarget.classList.remove('border', 'hover:bg-spotify-gray-highlight', 'bg-spotify-gray-clear')
      this.copyButtonTarget.classList.add('bg-spotify-green', 'font-bold')
      this.copyButtonTextTarget.innerHTML="Copied!"
      setTimeout(() => {
        this.copyButtonTextTarget.innerHTML="Invite"
        this.copyButtonTarget.classList.remove('bg-spotify-green')
        this.copyButtonTarget.classList.add('bg-spotify-gray-clear', 'border')
      }, 6000);
    })
    .catch(err => {
      console.error("Failed to copy: ", err);
    });
  }
   
  start(event) {
    const button = event.currentTarget;
    const startUrl = button.getAttribute('data-start-url');
    
    const currentlyPlayingElement = document.getElementById("currently_playing");
    currentlyPlayingElement.classList.add("hidden")
    
    this.toggleSpinner();
    
    fetch(startUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
    })
    .then(response => {
      if ([404,500,422].includes(response.status)) {
        throw new Error();
      }
      this.toggleSpinner();
      currentlyPlayingElement.classList.remove("hidden");
      })
    .catch(error => {
      this.toggleSpinner();
      this.toggleSpotifyError();
      setTimeout(() => {
        this.toggleSpotifyError();
        const currentlyPlayingElement = document.getElementById("currently_playing");
        currentlyPlayingElement.classList.remove("hidden");
      }, 3000);
     });
  }
  
  resume(event) {
    const button = event.currentTarget;
    const resumeUrl = button.getAttribute('data-resume-url');
    
    const currentlyPlayingElement = document.getElementById("currently_playing");
    currentlyPlayingElement.classList.add("hidden")
    
    this.toggleSpinner();
    
    fetch(resumeUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
    })
    .then(response => {
      if ([404,500,422].includes(response.status)) {
        throw new Error();
      }
      this.toggleSpinner();
      currentlyPlayingElement.classList.remove("hidden");
      })
    .catch(error => {
      this.toggleSpinner();
      this.toggleSpotifyError();
      setTimeout(() => {
        this.toggleSpotifyError();
        const currentlyPlayingElement = document.getElementById("currently_playing");
        currentlyPlayingElement.classList.remove("hidden");
      }, 3000);
     });
  }
  
  stop(event) {
    const button = event.currentTarget;
    const stopUrl = button.getAttribute('data-stop-url');
    
    const currentlyPlayingElement = document.getElementById("currently_playing");
    currentlyPlayingElement.classList.add("hidden")
    
    this.toggleSpinner();
    
    fetch(stopUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
    })
    .then(response => {
      if ([404,500,422].includes(response.status)) {
        throw new Error();
      }
      this.toggleSpinner();
      currentlyPlayingElement.classList.remove("hidden");
      })
    .catch(error => {
      this.toggleSpinner();
      this.toggleSpotifyError();
      setTimeout(() => {
        this.toggleSpotifyError();
        const currentlyPlayingElement = document.getElementById("currently_playing");
        currentlyPlayingElement.classList.remove("hidden");
      }, 3000);
     });
  }
  
  skip(event) {
    const button = event.currentTarget;
    const skipUrl = button.getAttribute('data-skip-url');
    
    const currentlyPlayingElement = document.getElementById("currently_playing");
    currentlyPlayingElement.classList.add("hidden")
    
    this.toggleSpinner();
    
    fetch(skipUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
    })
    .then(response => {
      if ([404,500,422].includes(response.status)) {
        throw new Error();
      }
      this.toggleSpinner();
      currentlyPlayingElement.classList.remove("hidden");
      })
    .catch(error => {
      this.toggleSpinner();
      this.toggleSpotifyError();
      setTimeout(() => {
        this.toggleSpotifyError();
        const currentlyPlayingElement = document.getElementById("currently_playing");
        currentlyPlayingElement.classList.remove("hidden");
      }, 3000);
     });
  }
  
  toggleSpinner() {
    let spinner = this.spinnerTarget 

    if (spinner.classList.contains("hidden")) {
      spinner.classList.remove("hidden");
    } else {
      spinner.classList.add("hidden")
    }
  }
  
  toggleSpotifyError() {
    let error = this.spotifyErrorTarget 

    if (error.classList.contains("hidden")) {
      error.classList.remove("hidden");
    } else {
      error.classList.add("hidden")
    }
  }
}
