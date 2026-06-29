import { Controller } from "@hotwired/stimulus"
import consumer from "channels"

export default class extends Controller {
  static targets = [
    "dropzone", "input", "preview", "previewContainer", "loadingState", "resetButton", "previewCaption",
    "auditResultsContainer", "summaryResult", "accessibilityResult", "hierarchyResult", "frictionResult"
  ]

  connect() {
    this.visionSubscription = consumer.subscriptions.create("VisionChannel", {
      connected() {
        console.log("Subscribed to VisionChannel")
      },
      received: (data) => {
        if (data.status === 'acknowledged') {
          console.log("Server acknowledged image receipt");
          // Optional: update UI to "Analysis in progress..."
        } else {
          this.handleResponse(data)
        }
      }
    })
  }

  handleResponse(data) {
    const { agent_id, content } = data;

    if (!agent_id || !content) return;

    const card = document.getElementById(`card-${agent_id}`);
    if (card) {
      const loader = card.querySelector(".loader");
      const result = card.querySelector(".result");

      if (loader) loader.classList.add("hidden");
      
      if (result) {
        // Use marked for markdown rendering if available
        if (window.marked) {
          result.innerHTML = window.marked.parse(content);
        } else {
          result.textContent = content;
        }
        result.classList.remove("hidden");
        // Simple pop-in animation via CSS or JS logic
        result.classList.add("animate-in", "fade-in", "slide-in-from-bottom-2", "duration-500");
      }
    }

    this.hideLoadingState();
  }

  // Removed parseAuditResponse and updateAuditUI as they were for the single-block response


  selectImage(event) {
    event.preventDefault()
    this.inputTarget.click()
  }

  dragover(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropzoneTarget.classList.add("border-indigo-500", "bg-indigo-50")
    this.dropzoneTarget.classList.remove("border-gray-300", "bg-white")
  }

  dragleave(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropzoneTarget.classList.remove("border-indigo-500", "bg-indigo-50")
    this.dropzoneTarget.classList.add("border-gray-300", "bg-white")
  }

  drop(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dragleave(event)

    const files = event.dataTransfer.files
    if (files && files.length > 0) {
      this.handleFile(files[0])
    }
  }

  async handleFile(event) {
    const file = event instanceof File ? event : event.target.files[0]
    
    if (!file) return

    this.showPreview(file)
    this.showLoadingState()
    this.resetExpertCards()

    try {
      const processedBlob = await this.resizeImage(file)
      const base64String = await this.blobToBase64(processedBlob)

      const payloadSizeKB = Math.round(base64String.length / 1024);
      console.log(`VisionController: Sending image to ActionCable. Size: ${payloadSizeKB}KB`, {
        length: base64String.length,
        filename: file.name
      });

      if (!this.visionSubscription) {
        console.error("VisionController: No active ActionCable subscription!");
        throw new Error("WebSocket not connected");
      }

      this.visionSubscription.send({ 
        image: base64String, 
        filename: file.name 
      })
    } catch (error) {

      console.error("Error processing image:", error)
      this.hideLoadingState()
    }
  }

  resetExpertCards() {
    const cards = document.querySelectorAll(".expert-card");
    cards.forEach(card => {
      const loader = card.querySelector(".loader");
      const result = card.querySelector(".result");

      if (loader) {
        loader.classList.remove("hidden");
        const statusText = loader.querySelector("span");
        if (statusText) statusText.textContent = "Analyzing...";
      }
      if (result) {
        result.classList.add("hidden");
        result.innerHTML = "";
      }
    });
  }

  async resizeImage(file) {
    const MAX_WIDTH = 800
    const MAX_HEIGHT = 800
    const QUALITY = 0.7

    return new Promise((resolve, reject) => {
      const img = new Image()
      img.src = URL.createObjectURL(file)

      img.onload = () => {
        URL.revokeObjectURL(img.src)

        let width = img.width
        let height = img.height

        if (width > MAX_WIDTH || height > MAX_HEIGHT) {
          if (width > height) {
            height = Math.round((height * MAX_WIDTH) / width)
            width = MAX_WIDTH
          } else {
            width = Math.round((width * MAX_HEIGHT) / height)
            height = MAX_HEIGHT
          }
        }

        const canvas = document.createElement("canvas")
        canvas.width = width
        canvas.height = height

        const ctx = canvas.getContext("2d")
        ctx.drawImage(img, 0, 0, width, height)

        canvas.toBlob(
          (blob) => resolve(blob),
          "image/jpeg",
          QUALITY
        )
      }

      img.onerror = (error) => reject(error)
    })
  }

  showPreview(file) {
    const url = URL.createObjectURL(file)
    this.previewTarget.src = url
    
    this.dropzoneTarget.classList.add("hidden")
    this.previewContainerTarget.classList.remove("hidden")
  }

  showLoadingState() {
    this.loadingStateTarget.classList.remove("hidden")
    this.resetButtonTarget.classList.add("hidden")
    if (this.hasPreviewCaptionTarget) {
      this.previewCaptionTarget.classList.add("hidden")
    }
  }

  hideLoadingState() {
    this.loadingStateTarget.classList.add("hidden")
    this.resetButtonTarget.classList.remove("hidden")
    if (this.hasPreviewCaptionTarget) {
      this.previewCaptionTarget.classList.remove("hidden")
    }
  }

  async blobToBase64(blob) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.onloadend = () => resolve(reader.result)
      reader.onerror = reject
      reader.readAsDataURL(blob)
    })
  }


  resetImage(event) {
    event.preventDefault()
    
    // Revoke the object URL to prevent memory leaks
    if (this.previewTarget.src.startsWith("blob:")) {
      URL.revokeObjectURL(this.previewTarget.src)
    }
    
    this.previewTarget.src = ""
    this.inputTarget.value = ""
    
    this.dropzoneTarget.classList.remove("hidden")
    this.previewContainerTarget.classList.add("hidden")

    this.resetExpertCardsToDefault();
  }

  resetExpertCardsToDefault() {
    const cards = document.querySelectorAll(".expert-card");
    cards.forEach(card => {
      const loader = card.querySelector(".loader");
      const result = card.querySelector(".result");

      if (loader) {
        loader.classList.remove("hidden");
        const statusText = loader.querySelector("span");
        if (statusText) statusText.textContent = "Waiting for upload...";
      }
      if (result) {
        result.classList.add("hidden");
        result.innerHTML = "";
      }
    });
  }

}
