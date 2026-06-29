# Analysis: Vision Analysis Crash & Data Retrieval Failure

## Issue Summary
The previous fix addressed the `NoMethodError` caused by calling `.dig` directly on the `Cerebras::ResponseWrapper`. However, the system is still "not working" (UI does not update) because the `ResponseWrapper` implementation performs **recursive wrapping** but providing only a **shallow `.to_h`**.

## Technical Root Cause
In `ruby-sdk/lib/cerebras/response_wrapper.rb`, the `wrap_value` method ensures that every nested Hash is also wrapped in a `ResponseWrapper`.

When the service executes:
```ruby
response_hash = response.to_h
message = response_hash.dig('choices', 0, 'message')
```
The resulting `message` object is not a Ruby `Hash`, but another `Cerebras::ResponseWrapper` instance. Because `ResponseWrapper` does not implement the `[]` method, `message['content']` returns `nil` (or crashes depending on the Ruby version/context), resulting in empty strings being sent back to the UI.

## History of Attempted Fixes

| Version | Approach | Result | Why it failed |
|---|---|---|---|
| v1.0 | `response.to_h` $\rightarrow$ `.dig('choices', 0, 'message')` | No Crash, No Data | `.to_h` was shallow; nested objects remained `ResponseWrapper` instances which don't support `[]`. |

## Proposed Solution (v2.0)

We will pivot from "Hash-style" access to "Object-style" access, which is what the `ResponseWrapper` was specifically designed for via `method_missing`.

### Changes to `VisionAnalysisService`
1.  **Remove `.to_h` dependency**: Stop trying to cast the wrapper to a hash.
2.  **Use Dot Notation**: Access data using `response.choices[0].message.content`.
3.  **Safe Navigation**: Use `&.` or explicit checks to handle cases where `choices` might be empty.
4.  **Enhanced Logging**: Log the class of the objects at each level of the response chain to verify the traversal.

### Verification Plan
1.  **Log Inspection**: Verify `log/development.log` shows the transition from `ResponseWrapper` $\rightarrow$ `Array` $\rightarrow$ `ResponseWrapper` $\rightarrow$ `String`.
2.  **UI Test**: Confirm that the "Analysing..." state is replaced by actual model output.
3.  **Spec Update**: Update `vision_analysis_service_spec.rb` to ensure the mock objects correctly simulate the method-chaining behavior of the actual SDK.
