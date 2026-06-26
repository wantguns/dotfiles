import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

function quote(text: string): string {
  return text
    .split("\n")
    .map((line) => (line.length ? `> ${line}` : ">"))
    .join("\n");
}

export default function (pi: ExtensionAPI) {
  let lastReply: string[] = [];

  pi.on("input", () => {
    lastReply = [];
  });

  pi.on("message_end", (event) => {
    const message = event.message;
    if (message.role !== "assistant" || !Array.isArray(message.content)) return;
    const text = message.content
      .filter((block): block is { type: "text"; text: string } => block.type === "text")
      .map((block) => block.text)
      .join("\n")
      .trim();
    if (text) lastReply.push(text);
  });

  const openQuote = async (ctx: ExtensionContext) => {
    const output = lastReply.join("\n\n").trim();
    if (!output) {
      ctx.ui.notify("Nothing to quote yet", "info");
      return;
    }
    const reply = await ctx.ui.editor("Quote reply", `${quote(output)}\n\n`);
    if (reply && reply.trim()) {
      ctx.ui.setEditorText(reply);
    }
  };

  pi.registerCommand("quote", {
    description: "Quote the last reply and open the editor for an inline response",
    handler: async (_args, ctx) => openQuote(ctx),
  });

  pi.registerShortcut("ctrl+q", {
    description: "Quote the last reply and open the editor",
    handler: (ctx) => openQuote(ctx),
  });
}
