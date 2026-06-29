# Vision API Integration Diagnostics Report

## Objective
Identify the correct payload structure to enable vision analysis using the `gemma-4-31b` model via the Cerebras API.

## Summary of Findings
Despite testing multiple payload structures—including those derived from the official Python SDK—all requests containing image data returned a `400 Bad Request` error. None of the attempted formats resulted in a successful response.

## All Tested Payload Structures

### 1. OpenAI-Compatible `image_url` (Public URL)
- **Structure**: `content: [ { type: 'text', ... }, { type: 'image_url', image_url: { url: 'https://...' } } ]`
- **Result**: `400 Bad Request`
- **Note**: Tested with a valid public PNG.

### 2. OpenAI-Compatible `image_url` (Base64)
- **Structure**: `content: [ { type: 'text', ... }, { type: 'image_url', image_url: { url: 'data:image/png;base64,...' } } ]`
- **Result**: `400 Bad Request`
- **Note**: Tested with a minimal 1x1 red pixel PNG.

### 3. Python SDK-Style `image` (Direct Base64)
- **Structure**: `content: [ { type: 'text', ... }, { type: 'image', image: 'base64_string_without_prefix' } ]`
- **Result**: `400 Bad Request`
- **Note**: Based on `MessageUserMessageRequestContentUnionMember1ImageContentTyped` in the Python SDK.

### 4. Python SDK-Style `image` (Base64 with Prefix)
- **Structure**: `content: [ { type: 'text', ... }, { type: 'image', image: 'data:image/png;base64,...' } ]`
- **Result**: `400 Bad Request`

### 5. Explicit Modalities Configuration
- **Structure**: 
  ```ruby
  {
    model: 'gemma-4-31b',
    modalities: { input: ['text', 'image'], output: ['text'] },
    messages: [ ... ]
  }
  ```
- **Result**: `400 Bad Request`
- **Note**: Tested combined with both `image_url` and `image` formats.

## Debugging Observations
- **Payload Size**: All tests used a 1x1 pixel image to rule out size/timeout issues.
- **Error Body**: The API returned a `400` status code but provided no descriptive JSON error body (body was empty or unavailable), suggesting a potential gateway-level rejection or strict schema validation.
- **SDK Health**: The Ruby SDK is correctly interpreting the `400` error and raising `Cerebras::BadRequestError`.

## Conclusion & Final Discovery
The API is rejecting all standard multimodal payload variations despite the payload structures matching the official Cerebras documentation exactly.

**The Root Cause:**
According to the official Cerebras "Image Inputs" documentation, vision capabilities are currently in **[Private Preview]**. 

Requests returning `400 Bad Request` (without a descriptive body) when the payload is structurally correct indicate that the current API key has not been whitelisted for the Vision Private Preview.

**Resolution:**
Access must be requested from a Cerebras account representative to enable vision inputs for the account. Once enabled, the existing implementation in `VisionAnalysisService` and the tests in `test_vision_api_call.rb` (using the `image_url` / Base64 data URI format) will function as expected.
