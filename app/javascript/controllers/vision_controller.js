import { Controller } from "@hotwired/stimulus"
import consumer from "channels"

export default class extends Controller {
  static targets = ["stream", "canvas"]

  connect() {
    this.initCamera()
    this.visionSubscription = consumer.subscriptions.create("VisionChannel", {
      connected() {
        console.log("Subscribed to VisionChannel")
      },
      received(data) {
        const reasoningEl = document.getElementById("vision-reasoning")
        const answerEl = document.getElementById("vision-answer")
        const button = document.getElementById("capture-button")

        if (reasoningEl && data.reasoning) {
          reasoningEl.textContent = data.reasoning
        }
        if (answerEl && data.answer) {
          answerEl.textContent = data.answer
        }
        if (button) {
          button.disabled = false
          button.textContent = "Capture Frame"
          button.classList.remove("opacity-50", "cursor-not-allowed")
        }
      }
    })
  }

  async initCamera() {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ 
        video: { 
          facingMode: "user",
          width: { ideal: 1280 },
          height: { ideal: 720 }
        }, 
        audio: false 
      })
      
      this.streamTarget.srcObject = stream
      console.log("Webcam stream initialized successfully")
    } catch (error) {
      console.error("Error accessing webcam:", error)
      alert("Could not access webcam. Please ensure you have granted camera permissions.")
    }
  }

  capture() {
    const video = this.streamTarget
    const canvas = this.canvasTarget
    const context = canvas.getContext("2d")

    // Update button state immediately
    const button = document.getElementById("capture-button")
    if (button) {
      button.disabled = true
      button.textContent = "Analyzing..."
      button.classList.add("opacity-50", "cursor-not-allowed")
    }

    // Match canvas size to video stream dimensions
    canvas.width = video.videoWidth
    canvas.height = video.videoHeight

    context.drawImage(video, 0, 0, canvas.width, canvas.height)

    const base64Image = canvas.toDataURL("image/jpeg", 0.8)
    
    console.log("Captured Frame (Base64):", base64Image)
    
    if (this.visionSubscription) {
      this.visionSubscription.send({ image: base64Image })
    }

    this.flashCapture()
  }

  flashCapture() {
    const videoContainer = this.streamTarget.parentElement
    videoContainer.classList.add("ring-4", "ring-white")
    setTimeout(() => {
      videoContainer.classList.remove("ring-4", "ring-white")
    }, 100)
  }
}
