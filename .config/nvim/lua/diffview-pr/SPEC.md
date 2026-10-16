# diffview-pr — v1 spec

## Problem Statement

I review GitHub PRs in diffview-plus. Its file panel lets me mark files with `w`, and those marks persist between sessions. That is the most comfortable review flow I have.

But the marks live only in Neovim. GitHub has its own "Viewed" checkbox per file, and the two never agree. If I review in Neovim, the PR page still shows every file as unviewed. If I tick files in the browser, Neovim does not know.

octo.nvim does sync the Viewed flag, but its diffs are much less useful to me than diffview-plus's.

## Solution

A small Neovim module on top of diffview-plus. It is not a fork. It uses only the public hooks and the public selections API.

I run `:DiffviewPR` on a PR branch. It opens a diffview-plus diff that matches the PR's diff on GitHub. The file marks in the panel become the PR's Viewed flags:

- On open, the marks are loaded from GitHub.
- Each time I press `w`, the change is sent to GitHub.
- If GitHub is out of reach, the change waits in a local store and is sent later.

Normal `:DiffviewOpen` views are not touched.

## User Stories

1. As a reviewer, I want to run `:DiffviewPR` on my checked-out PR branch, so that I get a diffview of the PR without typing the rev range.
2. As a reviewer, I want to run `:DiffviewPR 123`, so that the PR is checked out and opened in one step.
3. As a reviewer, I want the base branch fetched before the diff opens, so that the file list matches GitHub's.
4. As a reviewer, I want the diff to use the merge base (`origin/<base>...HEAD`), so that I see the same changes as the PR page.
5. As a reviewer, I want the right side of the diff to be my real working-tree files, so that the LSP works while I review.
6. As a reviewer, I want files I marked Viewed on GitHub to show as marked when the diff opens, so that I don't re-review them.
7. As a reviewer, I want files GitHub shows as unviewed to show as unmarked on open, so that GitHub stays the source of truth.
8. As a reviewer, I want files that changed after I viewed them to show as unmarked, so that I review the new version.
9. As a reviewer, I want pressing `w` on a file to tick its Viewed checkbox on GitHub, so that the PR page shows my progress.
10. As a reviewer, I want pressing `w` again to untick it on GitHub, so that I can undo a mark.
11. As a reviewer, I want marking several files quickly to send one batch of changes, not one call per keypress, so that GitHub isn't flooded.
12. As a reviewer, I want the GitHub calls to be async, so that Neovim never freezes while I review.
13. As a reviewer, I want a short message when the diff opens (for example `PR #123 synced · 5/12 viewed`), so that I know sync is on.
14. As a reviewer, I want an error message when a write to GitHub fails, so that I know my mark did not reach the PR.
15. As a reviewer, I want failed writes kept and sent again on the next open, so that offline marks are not lost.
16. As a reviewer, I want `:DiffviewPRSync` to check the PR head again, pull the GitHub state and send pending writes, so that I can refresh after using the browser or after a push.
17. As a reviewer, I want sync to go read-only when my local HEAD differs from the PR head, so that I never mark a version I didn't read.
18. As a reviewer, I want a warning that explains why sync is read-only, so that I know to pull or check out.
19. As a reviewer, I want to still read the diff in read-only mode, so that a stale branch doesn't block me.
20. As a reviewer, I want the diff to open with the local cache when GitHub's file states can't be read, so that I can keep working. If the PR lookup itself fails, nothing opens: the base branch is unknown.
21. As a reviewer, I want files that exist only in my local diff (uncommitted edits) to be markable locally, so that `w` keeps working on them.
22. As a reviewer, I want those local-only files never sent to GitHub, so that no calls fail on paths the PR doesn't have.
23. As a reviewer, I want files in the PR that are missing from my diff to be ignored, so that their GitHub state is never touched.
24. As a reviewer, I want renamed files to sync by their new path, so that renames need no special handling.
25. As a reviewer, I want `C` (clear all marks) disabled in PR views, with a short message, so that one key can't unmark the whole PR on GitHub.
26. As a reviewer, I want `C` to keep working in normal diffviews, so that PR mode doesn't change my other workflows.
27. As a reviewer, I want the local marks dropped when the PR head changes, so that stale marks from an old commit don't come back.
28. As a reviewer, I want old entries removed from the local store after 30 days, so that the file doesn't grow forever.
29. As a reviewer, I want entries with pending writes never removed, so that cleanup can't lose unsent marks.
30. As a reviewer, I want PRs from forks to work, so that I can review outside contributions the same way.
31. As a reviewer, I want PRs with more than 100 files to sync fully, so that large PRs are not cut off.

## Implementation Decisions

**Extension, not a fork.** The module uses diffview-plus's public surface where it can:

- `diffview.api.selections` (`get_paths`, `set`),
- the file panel keymap config, for the `C` override.

It also uses three events that have no public hook:

- `selection_changed` and `view_closed` on `DiffviewGlobal.emitter`. They are the same events the config hooks wrap, but they can be added at runtime.
- `files_updated` on the view's own emitter. It is the only signal that the file list has loaded.

After applying marks, the module calls `view.panel:render()` and `redraw()`, because `selections.set()` does not redraw the panel.

Upstream updates stay a plain plugin update. If an update breaks something, it will be one of these three events.

**Modules.** There are three, named for what they do:

- **GitHub layer.** A thin wrapper over `gh`. It gets the PR for a branch or number (`gh pr view --json id,number,headRefOid,baseRefName`) and checks out a PR (`gh pr checkout`). It reads the viewed state and writes marks through `gh api graphql`. It has no logic.
- **Store.** The local JSON file in Neovim's data directory. It reads and writes entries, and prunes old entries on save.
- **Entry point.** It has the commands, the hook wiring, the `C` override, the debounce and the messages. It also holds the pure reconcile function.

**GitHub API contract.** The Viewed flag exists only in GraphQL:

- Read: `repository.pullRequest(number).files { path viewerViewedState }`, paged by 100. `viewerViewedState` is `VIEWED`, `UNVIEWED` or `DISMISSED`. `DISMISSED` means "viewed, then the file changed". It counts as not viewed.
- Write: the `markFileAsViewed` and `unmarkFileAsViewed` mutations, with the PR node ID and the path.

**Sync scope.** Sync is on only for views opened by `:DiffviewPR`. The module keeps a registry of those views. Hooks for other views return right away.

**Diff range.** `git fetch origin <base>`, then `DiffviewOpen origin/<base>...HEAD --imply-local`. With `--imply-local`, a side that resolves to local HEAD becomes the working tree.

**Store entry.** It is keyed by `owner/repo#<number>`:

- `head_sha`: the PR head the entry belongs to.
- `viewed`: the list of marked paths.
- `pending`: path → `true` (mark) or `false` (unmark), for writes not yet confirmed by GitHub.
- `updated_at`: the timestamp used for the 30-day pruning.

The built-in `persist_selections` still runs. The module overrides it on open with `selections.set()`.

**Reconcile (pure function).** Inputs:

- the GitHub state (path → viewed state), or none when `gh` failed,
- the local entry, or none,
- the current PR head SHA.

The diff paths are not an input: `selections.set()` already ignores paths that are not in the file list.

Output:

- the final set of marked paths,
- the writes to send (path → mark/unmark).

Rules:

- GitHub wins, and `DISMISSED` counts as unviewed.
- Pending writes override GitHub. They are returned as writes to send, unless GitHub already matches them.
- If the entry's `head_sha` differs from the current head, the local `viewed` set is dropped. Pending writes still apply.
- Paths not in the GitHub file list are kept locally and never returned as writes.
- If there is no GitHub state, the local set is used as is.

**Write path.** On `selection_changed`:

1. Diff the new selection against the last known set, then debounce about 1 second.
2. Send only the changed paths that exist in the PR.
3. On success, clear them from `pending`. On failure, keep them in `pending` and show an error.

If GitHub's file states are unknown (it was unreachable on open), every change waits in `pending` and nothing is sent. The next successful open or `:DiffviewPRSync` reconciles them, and pending writes for non-PR files are dropped there.

Each file refresh puts the session's marks back on the panel. Without that, a file that leaves the diff and comes back would show as unmarked, and the next change would send an unmark for it.

**Read-only mode.** This applies when local HEAD differs from the PR's `headRefOid`:

- The GitHub state loads.
- `w` still marks files locally, but nothing is queued or sent.
- A warning says why.

**`C` in PR views.** A no-op with a short message. In other views it calls the normal `clear_select_entries` action.

**Commands.** `:DiffviewPR [number]` and `:DiffviewPRSync`. No keymap.

## Testing Decisions

- The seam is the reconcile function. It is pure: plain tables in, plain tables out. It holds the logic most likely to go wrong. Tests call it with GitHub state, local entry, head SHA and diff paths, and assert the final set and the writes. They do not look at internals.
- Cases to cover:
  - GitHub wins over local.
  - `DISMISSED` counts as unviewed.
  - Pending marks and unmarks override GitHub.
  - A head change drops `viewed` but keeps `pending`.
  - Local-only paths never become writes.
  - The `gh` failure fallback.
  - Empty inputs.
- The GitHub layer, the store and the hook wiring are not tested in v1. They are thin, and a mocked `gh` would test the mock.
- Prior art: diffview-plus's own functional specs, which run with plenary's busted in headless Neovim.

## Out of Scope

Everything below waits for a later version. See `ROADMAP.md`.

- PR comments, reading or writing.
- Alerts that a file changed after I viewed it.
- Any keymap, and a PR-number prompt.
- A permanent sync-status label in the panel or lualine.
- Refresh when the diffview tab is re-entered.
- Tests for the GitHub layer and the store.
- Moving the module to its own repo.

## Further Notes

- The `gh` CLI must be installed and logged in. Version 2.96 is available.
- The dotfiles repo has no issue tracker, so this spec lives next to the module.
