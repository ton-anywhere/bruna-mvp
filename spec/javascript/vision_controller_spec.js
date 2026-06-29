
// Minimal test environment for logic check
// In a real Rails app we'd use Jest/RSpec-JS, but we can test the logic in a separate script
// Since we are using Stimulus, the parser logic should be a standalone method.

const { parseAuditResponse } = require('./vision_parser_logic')

describe('parseAuditResponse', () => {
  test('splits text into categories correctly', () => {
    const text = `General summary here.
### Accessibility
A1, A2
### Visual Hierarchy
V1, V2
### UX Friction
F1, F2`
    const result = parseAuditResponse(text)
    expect(result.summary).toBe('General summary here.')
    expect(result.accessibility).toBe('A1, A2')
    expect(result.hierarchy).toBe('V1, V2')
    expect(result.friction).toBe('F1, F2')
  })

  test('handles missing categories', () => {
    const text = `Summary only.
### Accessibility
A1`
    const result = parseAuditResponse(text)
    expect(result.summary).toBe('Summary only.')
    expect(result.accessibility).toBe('A1')
    expect(result.hierarchy).toBe('')
    expect(result.friction).toBe('')
  })

  test('handles no summary', () => {
    const text = `### Accessibility
A1`
    const result = parseAuditResponse(text)
    expect(result.summary).toBe('')
    expect(result.accessibility).toBe('A1')
  })
})
