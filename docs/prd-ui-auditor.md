# PRD: UI Auditor

## 1. Introduction/Overview
The **UI Auditor** is a real-time design critique tool. Instead of a live camera feed, users upload a screenshot of a user interface. The system utilizes the ultra-low latency of Gemma 4 on Cerebras to provide an instant, professional design audit. This tool aims to bridge the gap between "AI-generated slop" and professional-grade UX/UI by providing critical, standards-based feedback.

## 2. Goals
- **Zero-Lag Feedback:** Provide a design critique in milliseconds after the image is sent.
- **High-Signal Critique:** Move beyond generic praise to provide actionable, categorized feedback.
- **Anti-Slop Guidance:** Actively identify and discourage common AI-generated design anti-patterns.

## 3. User Stories
- **As a developer**, I want to drag and drop my UI screenshot into the app so that I can get an instant second opinion on my layout.
- **As a designer**, I want the feedback categorized by Accessibility, Visual Hierarchy, and UX Friction so that I can prioritize my fixes.
- **As a product owner**, I want the AI to flag "generic" design choices so that the final product feels bespoke and professional.

## 4. Functional Requirements
1. **Image Upload Interface:** The system must provide a designated drag-and-drop area and a file selection button for image uploads.
2. **Single File Limit:** The system must handle exactly one image file per request for the MVP.
3. **Client-Side Processing:** The browser must convert the uploaded image to a Base64 string before transmission.
4. **WebSocket Transport:** The image must be sent to the server via ActionCable to maintain the "Live Vision" pipeline.
5. **Categorized AI Analysis:** The system must prompt the LLM to return a response divided into three specific categories:
    - **Accessibility:** (e.g., Contrast, font size, WCAG compliance).
    - **Visual Hierarchy:** (e.g., Balance, focal points, alignment).
    - **UX Friction:** (e.g., Confusing navigation, redundant steps, cognitive load).
6. **Reasoning Separation:** The system must separate the LLM's internal reasoning tokens from the final critique delivered to the user.
7. **Camera Removal:** The existing webcam capture and streaming logic must be removed from the UI and backend.

## 5. Non-Goals (Out of Scope)
- **Multiple Image Uploads:** Not supported in MVP.
- **Image Annotation:** The AI will not draw on or highlight specific coordinates of the image.
- **Persistence:** No images or critiques will be saved to a database (Stateless flow).

## 6. Deferred to Future Phase
- **Project History:** Ability to compare "Before" and "After" screenshots.
- **Direct CSS Suggestions:** Moving from descriptive critique to providing actual CSS snippets for fixes.
- **Interactive Chat:** A follow-up conversation about the critique.

## 7. Data & External Dependencies
- **Model:** `gemma-4-31b` via Cerebras SDK.
- **Transport:** ActionCable (WebSockets).
- **Data Format:** Base64 encoded strings.

## 8. Design Considerations
- **Minimalist Interface:** A clean, centered upload zone.
- **Markdown Rendering:** The categorized feedback should be rendered as clean Markdown for readability.
- **State Indicators:** Visual feedback (e.g., a loader or "Analyzing..." state) while the WebSocket request is pending.

## 9. Technical Considerations
- **Payload Size:** Base64 strings can be large; ensure ActionCable/server limits accommodate standard screenshot sizes (**MVP-critical**).
- **System Prompting:** The prompt must explicitly instruct the model to avoid "generic AI praise" and instead act as a "ruthless but constructive senior design lead" (**MVP-critical**).

## 10. Success Metrics
- **Latency:** Time from "Send" to "Response" should be under 2 seconds.
- **Utility:** The AI must identify at least one legitimate design flaw in a known "bad" UI sample.

## 11. Open Questions
- Should we limit the maximum file size (e.g., 5MB) on the client side to prevent WebSocket overflow?
