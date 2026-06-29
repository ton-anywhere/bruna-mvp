# Task: Enhanced Diagnostic Logging for VisionAnalysisService

## Status
- [ ] Pending

## Objective
Improve observability of the `VisionAnalysisService` to identify why the vision pipeline is failing despite canonicalization and response hardening.

## Requirements
- **Request Visibility**: Log image size and request initiation.
- **Response Visibility**: Dump the full `response.inspect` result from the Cerebras SDK to see the raw data structure.
- **Traversal Visibility**: Log the number of choices and the keys/methods of the message object.
- **Extraction Visibility**: Log the final extracted reasoning and content before returning.
- **Error Visibility**: Enhance rescue blocks to log full exception objects and backtraces.

## Acceptance Criteria
- [ ] Logs show the length of the `image_url` sent.
- [ ] Logs show a full dump of the SDK response object.
- [ ] Logs show the final extracted result (or the specific point of failure in traversal).
- [ ] Critical errors output the full exception class and message.

## Handoff Notes
- File: `app/services/vision_analysis_service.rb`
- Do not modify the logic for base64 prefix stripping.
- Focus on `Rails.logger.debug` and `Rails.logger.error`.
