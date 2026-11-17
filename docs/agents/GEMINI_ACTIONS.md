# Gemini Actions — safe first stage

This is a manual, **read-only advisory** integration. It does not edit game code,
open PRs, trigger staging, or provide the Gemini Hydrogen app with GitHub access.

To activate after review and merge:
1. Create repository Actions secret `GEMINI_API_KEY` using a key from Google AI Studio.
   Never paste the key in chat, an issue, or a committed file.
2. Go to Actions > Gemini advisory review > Run workflow.
3. Provide a narrow task. Download the `gemini-advisory-report` artifact.

The workflow has `contents: read` only, does not persist checkout credentials,
and never executes generated model output. Gemini API quotas/billing are separate.

Before enabling autonomous edits, design an isolated executor, strict path
allowlist, patch validation, dedicated branches, draft PRs, CI gates, and
review requirements. Preserve `AGENTS.md` and the official task queue.
Only the existing staging pipeline may publish the shared Roblox Place.

## Scoped code proposals (second workflow)

`Gemini code proposal` is a manual workflow that requests a single existing
`.luau` file under `src/client/` or `src/server/`. It generates a bounded
replacement using the Gemini API, commits to a unique `gemini/proposal-*` branch,
and opens a **draft PR**. It never merges or publishes. Reviewers must check
the entire diff, agent ownership, Luau validity and project CI before approval.
The generated code is **not** executed in this workflow, and no Roblox runtime
validation is claimed.

Required configuration: repository Actions secret `GEMINI_API_KEY`; repository
Actions settings must permit workflows to create pull requests and the
`GITHUB_TOKEN` must have write permissions. Branch protection and repository
policy may prevent these actions, in which case use a reviewed alternative
rather than bypassing controls.

Run after merging this setup PR: Actions > Gemini code proposal > Run workflow;
provide a narrow task and one existing Luau file. Do not select a file currently
owned by another agent. Do not run concurrently with work on the same path.
This is a controlled proposal mechanism, **not** an autonomous multi-file agent,
and must not replace the official staging pipeline.
