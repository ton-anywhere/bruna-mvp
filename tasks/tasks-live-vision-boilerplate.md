## Tasks (High-Level Plan)

- [ ] 0.0 Initialize project environment
- [ ] 1.0 Basic Vision Frontend (The "Eyes")
- [ ] 2.0 Real-time Transport Layer (The "Nerves") _(deliverable: Server logs show arrival of Base64 image data from the client)_
- [ ] 3.0 SDK Integration Service (The "Brain Interface")
- [ ] 4.0 Closed-Loop Feedback (The "Response") _(deliverable: Full PoC loop: Capture -> Analyze -> Display)_
- [ ] 5.0 Verification & Latency Audit

## Milestones

| After    | You have                              |
|----------|---------------------------------------|
| **1.0**  | A web page that can access the camera and "freeze" a frame. |
| **2.0**  | A working WebSocket pipe that sends images from the browser to the server. |
| **4.0**  | **Full PoC**: A complete loop where a real-world object is identified by Gemma 4 and displayed on the page. |

## Notes
- This is a high-level plan. Detailed sub-tasks will be generated upon confirmation.
- Project uses a local Ruby SDK linked via `:path` in the Gemfile.
- Special handling for Cerebras reasoning tokens is required in the service layer.
