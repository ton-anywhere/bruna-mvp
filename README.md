# Bruna UI 🎨

A minimalist, high-performance design critique tool powered by **Gemma 4 on Cerebras**. 

Bruna UI provides instant, professional-grade UX/UI audits by analyzing screenshots and delivering actionable feedback via a panel of specialized AI agents—all with ultra-low latency.

## 🚀 Core Loop
`Upload Screenshot` -> `WebSocket Transport` -> `Gemma 4 Analysis` -> `Categorized Critique`

## ✨ Features
- **Zero-Lag Feedback:** Built for millisecond-level responses using Cerebras' inference speed.
- **High-Signal Audits:** Specifically prompted to avoid "AI praise" and provide ruthless, constructive senior-level design critiques.
- **Parallel Expert Panel:** Instead of a single response, Bruna UI dispatches the analysis to four specialized agents in parallel, streaming a "blind review" from each:
  - **Accessibility Lead:** Focuses on WCAG compliance and inclusive design.
  - **Visual Architect:** Critiques grid alignment, hierarchy, and professional polish.
  - **UX Psychologist:** Analyzes cognitive load and mental model friction.
  - **Copy Specialist:** Mercilessly edits for clarity, brevity, and conversion.
- **Stateless Pipeline:** Designed for instant "One Frame -> One Response" flow with no database overhead.

## 🛠️ Tech Stack
- **Backend:** Rails (Minimal mode)
- **Frontend:** Hotwire (Turbo + Stimulus)
- **Transport:** ActionCable (WebSockets) for low-latency image transmission.
- **AI Model:** `gemma-4-31b` via the local Cerebras Ruby SDK.
- **Data Flow:** Base64 encoded image pipeline.

## 📦 Getting Started

### Prerequisites
- Ruby installed
- A `CEREBRAS_API_KEY`

### Installation
1. Clone the repository.
2. Ensure the `cerebras` Ruby SDK is available at `../ruby-sdk` (as defined in the Gemfile).
3. Create a `.env` file in the root directory:
   ```env
   CEREBRAS_API_KEY=your_key_here
   ```
4. Install dependencies:
   ```bash
   bundle install
   ```

### Running the App
```bash
bin/dev
```

## 🏗️ Architecture Principles
- **Extreme Minimalism:** Only dependencies essential to the visual loop are included.
- **Local-First SDK:** Utilizes a local path for the SDK to ensure rapid iteration.
- **Reasoning Separation:** Explicitly separates model reasoning from the final critique to ensure a clean user experience.
