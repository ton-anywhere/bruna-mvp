## Instructions for Completing Tasks

**IMPORTANT:** As you complete each task, you must check it off in this markdown file by changing `- [ ]` to `- [x]`. This helps track progress and ensures you don't skip any steps.

Update the file after completing each sub-task, not just after completing an entire parent task.

## Tasks

- [ ] 0.0 Create feature branch
  - [ ] 0.1 Create and checkout a new branch for this feature (e.g., `git checkout -b feature/ui-auditor`)

- [ ] 1.0 Infrastructure & Cleanup
  - [ ] 1.1 Remove webcam initialization logic from `app/javascript/controllers/vision_controller.js` (remove `initCamera` and `flashCapture`).
  - [ ] 1.2 Remove legacy camera HTML elements from `app/views/home/index.html.erb` (remove `<video>`, legacy `canvas`, and "Capture Frame" button).
  - [ ] 1.3 Clean up `vision_controller.js` targets to remove `stream` and `canvas`.
  - [ ] 1.4 Verify the page loads without console errors related to missing camera permissions or elements.

- [ ] 2.0 Image Upload Interface
  - [ ] 2.1 Implement a drag-and-drop zone in `app/views/home/index.html.erb` using Tailwind CSS for a clean, centered upload area.
  - [ ] 2.2 Add a hidden file input and a "Select Image" button to trigger it.
  - [ ] 2.3 Implement `vision_controller.js` event listeners for `dragover`, `dragleave`, and `drop` to provide visual feedback (e.g., border color change).
  - [ ] 2.4 Implement a "preview" mechanism to show the uploaded image before sending it to the AI.

- [ ] 3.0 Image Processing Pipeline
  - [ ] 3.1 Create a helper method in `vision_controller.js` to convert the uploaded `File` object to a Base64 string using `FileReader`.
  - [ ] 3.2 Wire the conversion logic to the `drop` and `change` events.
  - [ ] 3.3 Modify the `visionSubscription.send` call to transmit the Base64 string and the filename.
  - [ ] 3.4 Implement "Analyzing..." UI state: disable upload zone and show a loading spinner/message while waiting for the WebSocket response.

- [ ] 4.0 Specialized Audit Service (deliverable: App accepts an image and returns a raw AI audit response)
  - [ ] 4.1 Update `app/services/vision_analysis_service.rb` system prompt: Instruct the model to act as a "ruthless but constructive senior design lead".
  - [ ] 4.2 Define strict output categories in the prompt: **Accessibility**, **Visual Hierarchy**, and **UX Friction**.
  - [ ] 4.3 Instruct the model to avoid generic praise and focus on standards-based critique (WCAG, cognitive load, alignment).
  - [ ] 4.4 Verify the output by calling the service with a known "bad" UI screenshot and checking for the three categories in the response.

- [ ] 5.0 Audit UI Enhancement
  - [ ] 5.1 Replace the `vision-answer` div in `app/views/home/index.html.erb` with a structured container capable of displaying categorized feedback.
  - [ ] 5.2 Implement a Markdown rendering solution (e.g., integrating a simple JS markdown library or using basic formatting) to display the AI response.
  - [ ] 5.3 Style the output categories (Accessibility, Visual Hierarchy, UX Friction) with distinct visual markers (e.g., badge colors) for readability.
  - [ ] 5.4 Update `vision_controller.js` `received` callback to inject the formatted response into the new structured container.

- [ ] 6.0 Performance & Constraint Hardening
  - [ ] 6.1 Implement client-side file validation in `vision_controller.js` to restrict files to images only (jpg, png, webp) and a maximum size of 5MB.
  - [ ] 6.2 Add an error notification UI in `index.html.erb` to alert the user if the file is too large or the wrong format.
  - [ ] 6.3 (Backend) Add a payload size check in `app/channels/vision_channel.rb` to prevent processing excessively large Base64 strings.

- [ ] 7.0 Final Verification
  - [ ] 7.1 End-to-End Test: Upload a sample UI $\rightarrow$ Observe "Analyzing" state $\rightarrow$ Receive categorized audit.
  - [ ] 7.2 Latency Audit: Measure time from upload to response; verify it is under 2 seconds.
  - [ ] 7.3 Quality Check: Verify that "reasoning" is kept separate from the final answer in the UI.

## Milestones

| After | You have |
|----------|---------------------------------------|
| **1.0** | A clean slate with no legacy camera code. |
| **3.0** | An app that can send a screenshot to the server via WebSockets. |
| **4.0** | A working end-to-end flow where an image triggers a professional design audit. |
| **5.0** | A polished UI that renders the audit in professional, categorized categories. |

## Relevant Files

- `app/javascript/controllers/vision_controller.js` — Core logic for upload, Base64 conversion, and WebSocket communication.
- `app/views/home/index.html.erb` — The main UI for the drag-and-drop zone and audit display.
- `app/services/vision_analysis_service.rb` — The prompt engineering and Cerebras SDK integration.
- `app/channels/vision_channel.rb` — The WebSocket entry point and transmission logic.

## Notes

- Ensure `CEREBRAS_API_KEY` is set in the `.env` file.
- Remember that the flow is stateless; no database is used.
- Base64 strings are large; if the app crashes during upload, check ActionCable memory limits.
