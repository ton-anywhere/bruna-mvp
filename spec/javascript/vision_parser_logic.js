
function parseAuditResponse(text) {
  if (!text) return { summary: "", accessibility: "", hierarchy: "", friction: "" };

  const result = {
    summary: "",
    accessibility: "",
    hierarchy: "",
    friction: ""
  };

  const sections = text.split(/###\s+(Accessibility|Visual Hierarchy|UX Friction)/i);
  
  // The first element is always the summary (or empty)
  result.summary = sections[0]?.trim() || "";

  for (let i = 1; i < sections.length; i += 2) {
    const header = sections[i].toLowerCase();
    const content = sections[i + 1]?.trim() || "";

    if (header.includes("accessibility")) {
      result.accessibility = content;
    } else if (header.includes("visual hierarchy")) {
      result.hierarchy = content;
    } else if (header.includes("ux friction")) {
      result.friction = content;
    }
  }

  return result;
}

module.exports = { parseAuditResponse };
