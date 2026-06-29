# Task: Fix Vision Analysis Backend Crash

## Description
Resolve the backend crash occurring in `VisionChannel#receive` caused by an incompatibility between the `VisionAnalysisService` and the `Cerebras` SDK's `ResponseWrapper`.

## Context
The `Cerebras::Client` returns a `ResponseWrapper` object instead of a standard Ruby Hash. The current implementation of `VisionAnalysisService` calls `.dig` on this object, which triggers a `NoMethodError` because `ResponseWrapper` does not implement `dig`. Additionally, the SDK uses string keys internally, but the service attempts to use symbols.

## Requirements

### 1. Fix Response Parsing
- Modify `app/services/vision_analysis_service.rb`.
- Convert the SDK response to a hash using `.to_h` before attempting to extract data.
- Use string keys (`'choices'`, `'message'`) instead of symbols (`:choices`, `:message`) during the `dig` operation to match the SDK's internal JSON structure.
- Ensure safe navigation to avoid `NoMethodError` if `choices` is empty or `message` is missing.

### 2. Standardize Image Payload
- Ensure the image passed to the SDK is a valid Data URI.
- If the `base64_image` string does not start with `data:image/`, prepend `data:image/jpeg;base64,` to it.

### 3. Error Handling
- Maintain the existing `rescue StandardError` block to ensure the service always returns a hash with `reasoning` and `answer` keys, preventing ActionCable transport crashes.

## Verification Criteria
- [ ] **No more crashes**: `log/development.log` should no longer show `Unable to process VisionChannel#receive`.
- [ ] **UI Transition**: The "Analysing..." state in the browser must be replaced by the model's reasoning and answer.
- [ ] **SDK Integration**: Verify that the `Cerebras::Client` is called with a correctly formatted Data URI.

## Implementation Notes
- **Constraint**: Do NOT modify any files inside the `/home/airtonp/code/ton-anywhere/hackaton-gemma-cerebras/ruby-sdk` folder. All fixes must be applied within the Rails boilerplate.
- **Relevant File**: `app/services/vision_analysis_service.rb`
