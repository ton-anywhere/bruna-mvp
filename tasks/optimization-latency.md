# Optimization Plan: Reducing AI Response Latency

## 1. Understanding
**Goal:** Reduce the "Time to Response" (TTR) from the moment a user uploads a screenshot until the AI audit is displayed.
**Current Observation:** Perceived slowdown after adding image reset/cleanup logic.

## 2. Bottleneck Analysis
*   **Payload Size:** High-resolution screenshots result in massive Base64 strings, slowing down WebSocket transmission and LLM processing.
*   **Render-Blocking Assets:** `marked.js` is loaded via CDN in the HTML, adding an external network request and bypassing the asset pipeline.
*   **DOM Overhead:** Frequent `querySelector` calls during the response phase.
*   **Synchronous Backend:** The Rails ActionCable worker is blocked while waiting for the LLM response.

## 3. Proposed Optimizations

### Phase 1: Frontend Payload Reduction (High Impact)
*   **Canvas Downscaling:** Implement a client-side resize step. Instead of converting the raw file to Base64, draw the image to a hidden `<canvas>` at a maximum resolution (e.g., 1920px) and export as a compressed JPEG/WebP.
*   **Result:** Dramatically smaller Base64 strings $\rightarrow$ faster upload $\rightarrow$ faster LLM vision processing.

### Phase 2: Asset Pipeline Optimization (Medium Impact)
*   **Bundle `marked.js`:** Move the markdown library from a CDN `<script>` tag into the Rails `importmap` or JS bundle.
*   **Result:** Eliminates a render-blocking external request.

### Phase 3: UI/UX Fluidity (Low-Medium Impact)
*   **Incremental Updates:** Refactor `handleResponse` to display the "Reasoning" block immediately upon arrival, followed by the "Answer" blocks, rather than waiting for a single batch DOM update.
*   **DOM Caching:** Cache target elements in `connect()` to avoid repeated `querySelector` lookups during the response loop.

## 4. Task Breakdown for Build Agent

### Task 1: Image Compression Pipeline
- [ ] Create a private method in `vision_controller.js` to resize images using a `canvas` element.
- [ ] Integration: Update `handleFile` to call the resizer before `fileToBase64`.
- [ ] Guard: Ensure the resizer does not upscale images smaller than the target resolution.

### Task 2: Asset Migration
- [ ] Add `marked` to `config/importmap.rb` (or appropriate JS manifest).
- [ ] Import `marked` in `vision_controller.js` or `application.js`.
- [ ] Remove the `<script>` tag from `app/views/home/index.html.erb`.

### Task 3: DOM & Response Tuning
- [ ] Refactor `updateAuditUI` to use cached targets.
- [ ] Optimize the `handleResponse` flow to reduce visual "pop-in" lag.

## 5. Verification Criteria
1. **Payload Size Check:** Verify in Rails logs that the `image` string length is significantly reduced for high-res uploads.
2. **Network Tab Audit:** Confirm no external requests to `cdn.jsdelivr.net` for `marked.min.js`.
3. **Latency Test:** Measure the time from "Drop" to "Response" to ensure it stays under the 2-second target.
