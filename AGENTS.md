# Agent Instructions & Contextual Anchor

## 🎯 Project Mission
Bruna UI is a minimalist, high-performance design critique tool powered by Gemma 4 on Cerebras. It provides instant, professional-grade UX/UI audits by analyzing screenshots and delivering actionable feedback via a panel of specialized AI agents—all with ultra-low latency.

## 🏗️ Core Architectural Principles (Non-Negotiable)
- **Extreme Minimalism:** Rails launched with `--minimal`. Only include dependencies explicitly required for the visual loop.
- **Pinned SDK:** The `cerebras` gem is pinned to version `0.1.0` and fetched directly from its GitHub repository via Bundler (`github: 'ton-anywhere/cerebras-cloud-sdk-ruby'`). Do not attempt to use a public gem version.
- **Low-Latency Transport:** Mandatory use of ActionCable (WebSockets) + Hotwire/Turbo. Standard HTTP POST requests for image transfer are forbidden.
- **Cerebras-Specific Handling:** The API is not generically OpenAI-compatible. Reasoning tokens must be handled as distinct data from the final content.

## Architecture

**Rails Minimal Monolith** with a Hotwire frontend (Turbo + Stimulus) and an ActionCable backend.

### Non-obvious decisions
- **Stateless Loop:** Bruna UI is designed for a "One Frame -> One Response" flow. No database persistence is required for the MVP.
- **Base64 Pipeline:** UI screenshots are uploaded as Base64 strings in the browser and passed directly through ActionCable to the SDK.
- **Reasoning Parsing:** The response from `gemma-4-31b` contains reasoning content that must be separated from the final answer in the UI to avoid "thought" leakage into the answer box.

## 📚 Essential Documentation
Before proposing code changes, consult:
1. **[The Blueprint]** `docs/prd-ui-auditor.md`
   - *Defines the functional requirements and the "Upload $\rightarrow$ Analyze $\rightarrow$ Display" loop.*
2. **[The Task List]** `tasks/tasks-ui-auditor.md`
   - *Tracks the current implementation phase and milestones.*

## 🔁 Development Loop (Mandatory)

```
┌─────────┐    ┌──────┐    ┌──────┐   ┌──────┐    ┌──────────┐
│ Tech    │───▶│ Plan │───▶│ Build │◀─▶│  QA  │───▶│ Human    │
│  Lead   │    │Agent │    │ Agent │   │Agent │    │(Report)  │
└─────────┘    └──────┘    └──────┘   └──────┘    └──────────┘
      ▲                                                      │
      └──────────────────────────────────────────────────────┘
```

**This loop is mandatory.**
- **Tech Lead**: Orchestrates and verifies. Never implements.
- **Plan Agent**: Reads and plans. No file modifications.
- **Build Agent**: Implements based on the approved task list.
- **QA Agent**: Verifies against the PRD and SDK requirements.

## 📚 Developer Reference

### Commands
```bash
# Setup
bundle install             # Install dependencies including the local SDK

# Development
bin/dev                     # Start Rails server and ActionCable
```

### Notable Configurations
- `Gemfile` — pins the SDK to `0.1.0` via `github: 'ton-anywhere/cerebras-cloud-sdk-ruby'`.
- `.env` — must contain the `CEREBRAS_API_KEY`.

### Standards
- **Code comments** — invoke the `code-comments` skill when writing or reviewing code to decide what comments to add, keep, or remove.
