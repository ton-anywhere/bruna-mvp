# Plan: Transition to "Expert Panel" Parallel Architecture

## 1. Understanding
The goal is to evolve the UI Auditor from a single general critique into a panel of four specialized agents: **Accessibility Lead, Visual Architect, UX Psychologist, and Copy Specialist**. To maintain the "Zero-Lag" promise, these agents must run in parallel on the backend and stream their results independently to a segmented frontend.

**Confirmed Facts:**
- **Transport:** ActionCable (WebSockets) must be used.
- **Model:** `gemma-4-31b` via local Cerebras SDK.
- **Constraint:** Latency must remain under 2 seconds.
- **UI:** Results should be mapped to specific sections of the page.

**Assumptions:**
- The backend can handle concurrent HTTP requests to the Cerebras API without rate-limiting issues (given the local SDK/API key setup).
- The frontend will use a "placeholder/skeleton" state for the four sections while waiting for responses.

## 2. Relevant Existing Context
- **PRD:** `docs/prd-ui-auditor.md` defines the base "One Frame $\rightarrow$ One Response" loop.
- **Architecture:** Minimal Rails monolith, stateless (no DB).
- **Constraint:** Reasoning tokens must be stripped/separated from the final output.

## 3. Task Breakdown

### Phase 1: Requirement & Doc Update
- **Update PRD:** Modify `docs/prd-ui-auditor.md` to replace "Categorized AI Analysis" with the "Parallel Expert Panel" specification.
- **Update Persona Definitions:** Document the specific "ruthless" constraints for each of the four agents (Accessibility, Visual, UX, Copy).

### Phase 2: Backend Parallelization
- **Parallel Request Logic:** Implement a mechanism to trigger four concurrent calls to the Cerebras SDK upon receiving a Base64 image.
- **Streaming Dispatch:** Instead of one `broadcast` message, implement a loop that broadcasts individual messages for each agent as they complete (or a structured object if preferred, though individual streams are faster for UX).
- **Prompt Specialization:** Create four distinct system prompts tailored to each agent's expertise.

### Phase 3: Frontend Segmented UI
- **UI Layout:** Create four distinct layout sections/cards for the agents.
- **State Management:** Implement "Analyzing..." loaders for each specific section.
- **WebSocket Routing:** Update the Stimulus controller to route incoming WebSocket data to the correct section based on an `agent_id` or `category` key in the payload.

### Phase 4: Verification
- **Latency Test:** Verify that the total time to receive all four responses is roughly equal to the time of the single slowest response.
- **Persona Validation:** Verify that the **Copy Specialist** is actually critiquing text and not layout.

## 4. Happy Path
1. User drops a screenshot into the upload zone.
2. The browser sends the Base64 image via ActionCable.
3. The Server fires 4 parallel requests to Cerebras.
4. As each response returns (e.g., Visual first, then Copy, then others), the corresponding section on the UI "pops in" with the critique.
5. The user sees a comprehensive, multi-dimensional audit in $<2$ seconds.

## 5. Edge Cases
- **Partial Failure:** One agent fails or timeouts while others succeed. (UI should show an "Error" state for that specific section only).
- **Payload Size:** Ensure the 4x parallel responses don't overflow the WebSocket buffer (unlikely for text, but must be monitored).
- **Race Conditions:** Ensure responses are mapped to the correct image request if a user uploads images in rapid succession.

## 6. Verification Criteria
- **Functional:** Each of the 4 sections must populate with distinct, persona-driven content.
- **Performance:** Total turnaround time from upload to "all sections filled" must be $\approx 2$ seconds.
- **Behavioral:** No "thought/reasoning" tokens should appear in the final UI sections.

## 7. Build Agent Handoff
**Goal:** Implement the Parallel Expert Panel architecture.

**Key Requirements:**
- Use **Parallel Execution** (Threads or Async) in Ruby to call the SDK.
- Use **Individual ActionCable broadcasts** to allow "pop-in" loading.
- Create **four distinct system prompts** (Accessibility, Visual, UX, Copy).
- Update the **Frontend** to have 4 designated slots that update dynamically.

**Relevant Areas:**
- ActionCable Channel/Subscription logic.
- Stimulus controller handling the incoming socket data.
- The service object interacting with the `cerebras` gem.

## 8. Open Questions
- Do we want the agents to "know" about each other (shared context), or should they be completely independent "blind" reviews for maximum objectivity? (Recommended: Independent for speed and distinct perspectives).
