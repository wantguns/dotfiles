import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const BLOCKED_TOOLS = ["write", "edit", "bash"];
const STATUS_KEY = "plan-mode";

export default function (pi: ExtensionAPI) {
  let toolsBeforePlan: string[] | null = null;

  pi.on("tool_call", (event) => {
    if (toolsBeforePlan && BLOCKED_TOOLS.includes(event.toolName)) {
      return {
        block: true,
        reason: `Plan mode is read-only. '${event.toolName}' is disabled. Describe the change and let the user run it, or exit with /plan.`,
      };
    }
  });

  pi.registerCommand("plan", {
    description: "Toggle read-only plan mode (blocks write/edit/bash)",
    handler: async (_args, ctx) => {
      if (toolsBeforePlan) {
        pi.setActiveTools(toolsBeforePlan);
        toolsBeforePlan = null;
        ctx.ui.setStatus(STATUS_KEY, undefined);
        ctx.ui.notify("Plan mode OFF", "info");
      } else {
        toolsBeforePlan = pi.getActiveTools();
        pi.setActiveTools(toolsBeforePlan.filter((t) => !BLOCKED_TOOLS.includes(t)));
        ctx.ui.setStatus(STATUS_KEY, "PLAN (read-only)");
        ctx.ui.notify("Plan mode ON", "info");
      }
    },
  });
}
