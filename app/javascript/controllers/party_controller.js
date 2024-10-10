import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
   static targets = ["input","copyButton","copyButtonText"]

  copy() {
    const inputValue = this.inputTarget.value;
 
     navigator.clipboard.writeText(inputValue)
       .then(() => {
         this.copyButtonTarget.classList.remove('border', 'hover:bg-spotify-gray-highlight', 'bg-spotify-gray-clear')
         this.copyButtonTarget.classList.add('bg-spotify-green')
         this.copyButtonTextTarget.innerHTML="Copied!"
         setTimeout(() => {
           this.copyButtonTextTarget.innerHTML="Copy Invite"
           this.copyButtonTarget.classList.remove('bg-spotify-green')
           this.copyButtonTarget.classList.add('bg-spotify-gray-clear', 'hover:bg-spotify-gray-highlight', 'border')
         }, 6000);
       })
       .catch(err => {
         console.error("Failed to copy: ", err);
       });
   }
}
