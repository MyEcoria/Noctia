---
name: effort
description: Choose how hard the lead session and each Noctia agent (reader, architect, security-reviewer, developer, tester) think. User-only command.
disable-model-invocation: true
argument-hint: show | reset | lead=high architect=high reader=low ...
---

The user ran `/noctia:effort $ARGUMENTS`.

Each argument is `role=level`. Roles: `lead` (the main session), `reader`, `architect`, `security-reviewer`, `developer`, `tester`. Levels: `low`, `medium`, `high`, `xhigh`, `max`, `default` (drop the choice and use the agent's own level). The lead cannot take `max`. `show` lists the current levels and `reset` drops every choice. No argument counts as `show`.

If an argument has another shape, do not run anything: explain the syntax.

Otherwise run this from the project root:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/set-effort.sh" $ARGUMENTS
```

Then, in the user's language:

1. Show the table the script printed.
2. With no argument, or `show`, ask which role they want to change and give an example such as `/noctia:effort architect=xhigh reader=low`.
3. For every choice just made for an agent, apply it yourself from now on in this session: pass `effort: <level>` on each Agent call for that role. These choices win over the effort written in the agent's file. A `default` means the agent's own level again.
4. If `lead` changed, tell the user it applies from the next session and that `/effort <level>` changes the current one. Do not change your own effort.

Good to know, say it only if the user asks why a level did not apply:
- The levels a model accepts depend on the model. A level it does not support runs as the highest one below it.
- The `CLAUDE_CODE_EFFORT_LEVEL` variable, a `maxEffortLevel` setting or an organization cap beats these choices.
- Thinking on or off cannot be set per agent: a subagent follows the session.

Where the choices live:
- Agents: `.noctia/effort` in the project (git-ignored). The session-start hook gives them to Claude, and the `noctia-mods` plugin enforces them when an agent runs, from Claude Code 2.1.287.
- Lead: the `effortLevel` setting of `.claude/settings.local.json`.

If the script fails because `jq` is missing, pass on its message as it is: the user has to add the line by hand.
