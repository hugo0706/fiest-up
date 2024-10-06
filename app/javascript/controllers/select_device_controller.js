import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["devicesGrid", "setDeviceButton"];

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
        this.toggleSetDeviceButton();
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
    this.toggleSetDeviceButton();
  }
  
  toggleSetDeviceButton() { 
    if (this.selectedDeviceId && this.selectedDeviceElement) {
      this.setDeviceButtonTarget.classList.remove("hidden");
    } else { 
      this.setDeviceButtonTarget.classList.add("hidden");
    }
  }
  
  setDevice(event) { 
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
      window.location.href = response.url;
    })
  }
}
