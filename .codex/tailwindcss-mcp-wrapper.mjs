#!/usr/bin/env node

console.log = (...args) => {
  console.error(...args);
};

try {
  await import("/home/airtonp/.npm-global/lib/node_modules/tailwindcss-mcp-server/build/index.js");
} catch (error) {
  console.error("Failed to start tailwindcss-mcp-server:", error);
  process.exit(1);
}
