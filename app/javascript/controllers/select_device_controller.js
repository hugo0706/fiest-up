import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["devicesGrid", "setDeviceButton", "spinner"];

  connect() {
    this.interval = setInterval(() => {
      this.refreshDevices();
    }, 3000);
  }

  disconnect() {
    clearInterval(this.interval);
  }

  refreshDevices() {
    fetch(this.element.getAttribute("data-device-fetch-url"))
      .then((response) => response.text())
      .then((html) => {
        this.devicesGridTarget.innerHTML = html;
        if (this.selectedDeviceId) {
          this.selectedDeviceElement = this.devicesGridTarget.querySelector(`[data-device-id="${this.selectedDeviceId}"]`);
          if (this.selectedDeviceElement) {
            this.selectedDeviceElement.classList.add('border-4', 'border-green-500');
          }
        }
        this.renderSetDeviceButton();
      });
  }
  
  selectDevice(event){
    const clickedElement = event.currentTarget;
    const deviceId = clickedElement.getAttribute('data-device-id');

    if (this.selectedDeviceElement) {
      this.selectedDeviceElement.classList.remove('border-4', 'border-green-500');
    }

    clickedElement.classList.add('border-4', 'border-green-500');

    this.selectedDeviceId = deviceId;
    this.selectedDeviceElement = clickedElement;
    this.renderSetDeviceButton();
  }
  
  renderSetDeviceButton() { 
    if (this.selectedDeviceId && this.selectedDeviceElement) {
      this.setDeviceButtonTarget.classList.remove("hidden");
    } else { 
      this.setDeviceButtonTarget.classList.add("hidden");
    }
  }
  
  removeSetDeviceButton() { 
    if(!this.setDeviceButtonTarget.classList.contains("hidden")){
      this.setDeviceButtonTarget.classList.add("hidden");
    }
  }
  
  setDevice(event) {
    this.removeSetDeviceButton();
    this.toggleSpinner();
    const data = {
      device_id: this.selectedDeviceId
    };

    fetch(this.element.getAttribute("data-device-set-url"), {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      body: JSON.stringify(data)
    })
    .then(response => {
      if ([404,500,422].includes(response.status)) {
        throw new Error();
      } else {
        return response.json();
      } 
      })
    .then(data => {
      window.location.href = data.redirect_url;
    })
    .catch(error => {
      this.toggleSpinner(event);
      this.showOpenSpotifyError(event);
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
  
  showOpenSpotifyError(event) { 
    const span = document.createElement("span");

    span.textContent = "We couldnt connect to your device. Open your Spotify app and try again";
    span.classList.add(
      "absolute",
      "bottom-20",
      "z-50",
      "p-4",
      "rounded-2xl",
      "w-auto",
      "place-self-center",
      "bg-red-500",
      "items-center",
      "font-semibold",
      "text-md",
      "lg:text-lg"
    );
    event.target.parentElement.appendChild(span);
    
    setTimeout(() => {
      span.remove();
      this.renderSetDeviceButton();
    }, 3000);
  }
}
