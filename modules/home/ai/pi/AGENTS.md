# AGENTS.md (global)

## Git / version control — hard rules

- NEVER run `git push` or any command that writes to a remote
  (push, push --force, push tags, `git remote ...` that hits the
  network, etc.). The user pushes. The agent never does.
- NEVER create a commit unless the user explicitly asks in that
  message. The user frequently keeps work as local-only commits to
  test now and squash/rewrite later; an unrequested commit or push
  corrupts that workflow.
- NEVER modify git history or refs without explicit instruction:
  no reset --hard, rebase, amend, branch -f, force operations.
- When code must reach another machine, STOP and print the exact
  command for the user to run. Do not run it yourself.
- Local file writes/edits to do the requested work are fine. The
  restriction is specifically on git state and anything that leaves
  the local working tree (network/remote/history).
