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
        this.handleResponse(data)
      }
    })
  }

  handleResponse(data) {
    const reasoningEl = document.getElementById("vision-reasoning")
    const answerEl = document.getElementById("vision-answer")

    if (reasoningEl && data.reasoning) {
      reasoningEl.textContent = data.reasoning
      reasoningEl.classList.remove("hidden")
    }

    if (data.answer) {
      const parsed = this.parseAuditResponse(data.answer)
      this.updateAuditUI(parsed)
      
      if (answerEl) {
        answerEl.classList.add("hidden")
      }
    }

    this.hideLoadingState()
  }

  parseAuditResponse(text) {
    if (!text) return { summary: "", accessibility: "", hierarchy: "", friction: "" };

    const result = {
      summary: "",
      accessibility: "",
      hierarchy: "",
      friction: ""
    };

    const sections = text.split(/###\s+(Accessibility|Visual Hierarchy|UX Friction)/i);
    
    result.summary = sections[0]?.trim() || "";

    for (let i = 1; i < sections.length; i += 2) {
      const header = sections[i].toLowerCase();
      const content = sections[i + 1]?.trim() || "";

      if (header.includes("accessibility")) {
        result.accessibility = content;
      } else if (header.includes("visual hierarchy")) {
        result.hierarchy = content;
      } else if (header.includes("ux friction")) {
        result.friction = content;
      }
    }

    return result;
  }

  updateAuditUI(parsed) {
    this.auditResultsContainerTarget.classList.remove("hidden")
    
    const mapping = [
      { key: 'summary', target: 'summaryResult' },
      { key: 'accessibility', target: 'accessibilityResult' },
      { key: 'hierarchy', target: 'hierarchyResult' },
      { key: 'friction', target: 'frictionResult' }
    ]

    let hasCategories = false

    mapping.forEach(({ key, target }) => {
      const content = parsed[key]
      const targetEl = this[target + "Target"]
      
      if (targetEl) {
        const textContainer = targetEl.querySelector('div')
        if (textContainer) {
          // Use marked for markdown rendering if available, otherwise fallback to textContent
          if (window.marked && content) {
            textContainer.innerHTML = window.marked.parse(content)
          } else {
            textContainer.textContent = content
          }
        }
        
        if (content && key !== 'summary') {
          hasCategories = true
          targetEl.classList.remove("hidden")
        } else if (key !== 'summary') {
          targetEl.classList.add("hidden")
        }
      }
    })

    // Summary-only fallback
    const summaryEl = this.summaryResultTarget
    if (summaryEl && !hasCategories) {
      const textContainer = summaryEl.querySelector('div')
      if (textContainer) {
        const fallbackMsg = "\n\n*No category-specific issues found.*"
        const currentContent = parsed.summary || ""
        if (window.marked) {
          textContainer.innerHTML = window.marked.parse(currentContent + fallbackMsg)
        } else {
          textContainer.textContent = currentContent + "\n\nNo category-specific issues found."
        }
      }
    }
  }


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

    try {
      const base64String = await this.fileToBase64(file)
      this.visionSubscription.send({ 
        image: base64String, 
        filename: file.name 
      })
    } catch (error) {
      console.error("Error processing image:", error)
      this.hideLoadingState()
    }
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

  fileToBase64(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.readAsDataURL(file)
      reader.onload = () => resolve(reader.result)
      reader.onerror = (error) => reject(error)
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

    // Clear AI analysis results
    this.auditResultsContainerTarget.classList.add("hidden")
    
    const reasoningEl = document.getElementById("vision-reasoning")
    if (reasoningEl) {
      reasoningEl.textContent = ""
      reasoningEl.classList.add("hidden")
    }

    const answerEl = document.getElementById("vision-answer")
    if (answerEl) {
      answerEl.classList.add("hidden")
    }
  }

}
