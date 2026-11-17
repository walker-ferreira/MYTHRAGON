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
