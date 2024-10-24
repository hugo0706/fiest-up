import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
   static targets = ["input","copyButton","copyButtonText", "startButton"]

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
    
    fetch(startUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
    })
  }
}
