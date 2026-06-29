import { Controller } from "@hotwired/stimulus"
import consumer from "channels"

export default class extends Controller {
  static targets = []

  connect() {
    this.visionSubscription = consumer.subscriptions.create("VisionChannel", {
      connected() {
        console.log("Subscribed to VisionChannel")
      },
      received(data) {
        const reasoningEl = document.getElementById("vision-reasoning")
        const answerEl = document.getElementById("vision-answer")

        if (reasoningEl && data.reasoning) {
          reasoningEl.textContent = data.reasoning
        }
        if (answerEl && data.answer) {
          answerEl.textContent = data.answer
        }
      }
    })
  }
}
