# PRD: Live Vision Validation Boilerplate

## 1. Introduction/Overview
The goal of this project is to create a minimal technical validator to prove the end-to-end flow of a "Live Vision" application. It will verify that a visual frame can be captured in the browser, transmitted via WebSockets to a Rails backend, processed by a custom Ruby SDK calling Cerebras (Gemma 4), and streamed back to the UI.

## 2. Goals
- **Validate Transport:** Confirm Base64 image data can move through ActionCable without corruption or excessive latency.
- **Validate SDK:** Confirm the Ruby SDK correctly formats and sends multimodal requests to Cerebras.
- **Validate UI Loop:** Confirm Hotwire/Turbo can update the page with the model's response in real-time.

## 3. User Stories
- **As a Developer**, I want to click a "Capture" button and see a live snapshot of my webcam so I can verify the image is correct.
- **As a Developer**, I want an "Analyze" button that sends that snapshot to Gemma 4 and displays the response on the screen without a page reload.

## 4. Functional Requirements
1. **Visual Capture:** The system must use the browser's `getUserMedia` API to display a live webcam feed and capture a single frame as a Base64 string upon request.
2. **Real-time Transport:** The system must send the captured image string to the Rails server using an ActionCable channel.
3. **SDK Integration:** The server must pass the image data to the Ruby SDK, which communicates with the Cerebras `gemma-4-31b` model.
4. **Asynchronous Response:** The system must receive the text response from the SDK and broadcast it back to the user via ActionCable.
5. **Dynamic UI Update:** The UI must use Turbo Streams to inject the model's response into a designated result area without refreshing the page.

## 5. Non-Goals (Out of Scope)
- **Continuous Streaming:** Automatic frame capture (timer-based) is not part of this validation.
- **Complex Prompting:** This is a connectivity test; sophisticated system prompts are out of scope.
- **Authentication:** No user accounts or API key management via UI; keys will be handled via `.env`.
- **Production Deployment:** The target is local validation.

## 6. Deferred to Future Phase
- **Screen Capture:** Deferred to the actual project phase; webcam is the primary validator.
- **Stateful Memory:** Deferred; this is a stateless "One Frame -> One Response" test.
- **Tool Calling:** Deferred; the goal is simple text output.

## 7. Data & External Dependencies
- **Cerebras API:** 
  - Endpoint: OpenAI-compatible structure but **not** generically compatible.
  - Model: `gemma-4-31b`.
  - **Special Requirement:** Must handle "Reasoning" tokens and response formats as specified in the `CEREBRAS_GEMMA4_PRIVATE_PREVIEW_README.md` (handle the separation of reasoning and content).
- **Browser APIs:** `navigator.mediaDevices.getUserMedia` and `HTMLCanvasElement`.

## 8. Design Considerations
- **Single Page Layout:** A simple page with:
  - Left side: Video feed + Capture/Analyze buttons.
  - Right side: A "Response" box for the LLM output. **Note:** This box should be able to distinguish between "Thinking" (Reasoning) and "Answer" (Content).
- **Visual Feedback:** Show a "Processing..." state in the UI while waiting for the SDK response.

## 9. Technical Considerations
- **ActionCable (MVP-Critical):** Must be configured to handle the image payload.
- **Turbo Streams (MVP-Critical):** Used for the "wow" factor of the instant update.
- **Ruby SDK (MVP-Critical):** The core component being validated. **Must implement the specific Cerebras-style response parsing for reasoning tokens.**
- **Base64 Compression (Deferrable):** Initially send raw Base64; optimize image quality/size if latency is high.

## 10. Success Metrics
- **Latency:** The time from "Analyze" click to "Response" appearing should be dominated by inference, not transport.
- **Correctness:** The model should be able to identify a simple object held up to the webcam.
- **Response Handling:** The system correctly parses and displays the output without crashing when reasoning tokens are present.

## 11. Open Questions
- Does the current Ruby SDK implementation already handle the specific `reasoning_content` or non-standard response fields of the Cerebras API? (To be verified during implementation).
