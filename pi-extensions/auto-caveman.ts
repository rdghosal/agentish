import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { readFileSync, existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const SKILL_PATH = join(homedir(), ".agents/skills/caveman/SKILL.md");

function stripFrontmatter(text: string): string {
  if (!text.startsWith("---")) return text;
  const end = text.indexOf("---", 3);
  if (end === -1) return text;
  return text.slice(end + 3).replace(/^\n+/, "");
}

// Eager synchronous load at module-eval time (before any sessions).
// Falls back to empty if file missing — async handler can try again on session_start.
let skillContent: string | null = null;
let skillLoaded = false;
let loadError: string | null = null;

try {
  if (existsSync(SKILL_PATH)) {
    skillContent = stripFrontmatter(readFileSync(SKILL_PATH, "utf-8"));
    skillLoaded = true;
  }
} catch (err) {
  loadError = err instanceof Error ? err.message : String(err);
}

function log(tag: string, message: string): void {
  const ts = new Date().toISOString();
  console.log(`[auto-caveman] ${ts} ${tag}: ${message}`);
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (event, ctx) => {
    if (event.reason !== "startup") {
      log("skip", `session_start reason=${event.reason}`);
      return;
    }

    // If already loaded synchronously at import time, just notify.
    if (skillLoaded) {
      ctx.ui.notify("auto-caveman: skill loaded ✓", "info");
      log("ready", `(${skillContent?.length ?? 0} chars, loaded at import)`);
      return;
    }

    // Otherwise try async load as fallback.
    try {
      const { readFile } = await import("node:fs/promises");
      const raw = await readFile(SKILL_PATH, "utf-8");
      skillContent = stripFrontmatter(raw);
      skillLoaded = true;
      loadError = null;
      ctx.ui.notify("auto-caveman: skill loaded ✓", "info");
      log("ready", `(${skillContent.length} chars, loaded async)`);
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      loadError = msg;
      ctx.ui.notify(`auto-caveman: failed to load — ${msg}`, "error");
      log("error", msg);
    }
  });

  pi.on("before_agent_start", (event) => {
    if (!skillLoaded || !skillContent) {
      log("skip", `before_agent_start skillLoaded=${skillLoaded} hasContent=${skillContent !== null}`);
      return;
    }

    return {
      systemPrompt:
        event.systemPrompt +
        "\n\n---\n\n## Communication Mode: Caveman\n\n" +
        skillContent,
    };
  });
}
