import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const ALLOWED_TOOLS = [
  "read",
  "grep",
  "find",
  "ls",
  "web_search",
  "code_search",
  "fetch_content",
  "get_search_content",
  "ctx_search",
  "ctx_stats",
  "ctx_doctor",
  "ctx_insight",
];
const STATUS_KEY = "plan-mode";

export default function (pi: ExtensionAPI) {
  let toolsBeforePlan: string[] | null = null;

  const toggle = (ctx: ExtensionContext) => {
    if (toolsBeforePlan) {
      pi.setActiveTools(toolsBeforePlan);
      toolsBeforePlan = null;
      ctx.ui.setStatus(STATUS_KEY, undefined);
      ctx.ui.notify("Plan mode OFF", "info");
    } else {
      toolsBeforePlan = pi.getActiveTools();
      pi.setActiveTools(toolsBeforePlan.filter((t) => ALLOWED_TOOLS.includes(t)));
      ctx.ui.setStatus(STATUS_KEY, "PLAN (read-only)");
      ctx.ui.notify("Plan mode ON", "info");
    }
  };

  pi.on("tool_call", (event) => {
    if (toolsBeforePlan && !ALLOWED_TOOLS.includes(event.toolName)) {
      return {
        block: true,
        reason: `Plan mode is read-only. '${event.toolName}' is blocked. Only read-only tools are allowed. Describe the change for the user to run, or exit plan mode with /plan.`,
      };
    }
  });

  pi.on("before_agent_start", (event) => {
    if (!toolsBeforePlan) return;
    return {
      systemPrompt: `${event.systemPrompt}\n\n<plan-mode>\nPlan mode is currently ON: this is a read-only session. Tools that write files, edit, run shell commands, or execute code are blocked, so you genuinely cannot apply changes right now. Do not say you "have no write tool" or invent workarounds. Instead:\n- Tell the user plan mode is active and that they must turn it off before you can make changes.\n- If the requested change is small, show the exact file path and the precise content or unified diff to write, so the user can apply or approve it quickly once plan mode is off.\n- You may still freely read, search, and research to plan the change.\n</plan-mode>`,
    };
  });

  pi.registerCommand("plan", {
    description: "Toggle read-only plan mode (read-only tools only)",
    handler: async (_args, ctx) => toggle(ctx),
  });

  pi.registerShortcut("ctrl+\\", {
    description: "Toggle read-only plan mode",
    handler: (ctx) => toggle(ctx),
  });
}
