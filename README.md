# UI Auditor 🎨

A minimalist, high-performance design critique tool powered by **Gemma 4 on Cerebras**. 

The UI Auditor provides instant, professional-grade UX/UI audits by analyzing screenshots and delivering actionable feedback across Accessibility, Visual Hierarchy, and UX Friction—all with ultra-low latency.

## 🚀 Core Loop
`Upload Screenshot` $\rightarrow$ `WebSocket Transport` $\rightarrow$ `Gemma 4 Analysis` $\rightarrow$ `Categorized Critique`

## ✨ Features
- **Zero-Lag Feedback:** Built for millisecond-level responses using Cerebras' inference speed.
- **High-Signal Audits:** Specifically prompted to avoid "AI praise" and provide ruthless, constructive senior-level design critiques.
- **Categorized Insights:**
  - **Accessibility:** Contrast, font size, and WCAG compliance.
  - **Visual Hierarchy:** Balance, focal points, and alignment.
  - **UX Friction:** Navigation hurdles and cognitive load.
- **Stateless Pipeline:** Designed for instant "One Frame $\rightarrow$ One Response" flow with no database overhead.

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
