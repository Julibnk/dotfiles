# diffview-pr — roadmap

Ideas left out of v1 on purpose. Each one is independent of the others.

## Review features

- **PR comments.** Show review comments on the diff lines, and maybe write new ones. octo.nvim already does this, so check whether its code can be reused.
- **"Changed since viewed" alerts.** GitHub marks a file `DISMISSED` when it changes after I viewed it. v1 treats that as unviewed. A later version could show those files with their own sign in the panel.

## Usability

- **Keymap.** For example `<leader>gr` for `:DiffviewPR`.
- **PR-number prompt.** A keymap that asks for a PR number with `vim.ui.input`, then checks it out and opens it.
- **Status label.** A permanent label in the file panel or lualine: synced, read-only, pending writes, or error.
- **Refresh on tab enter.** Pull the GitHub state each time I switch back to the diffview tab. Throttle it, so it doesn't call GitHub on every switch.
- **Queue marks in read-only mode.** Keep local marks made while HEAD differs from the PR head, and send them once the branch is up to date.

## Store

- **Prune merged or closed PRs.** Delete entries for PRs that are no longer open, on top of the 30-day age rule. This needs a GitHub call per entry.

## Quality

- **Tests for the GitHub layer and the store.** Use a fake `gh` executable on `PATH`, and a temp file for the store.

## Packaging

- **Own repo.** Move the module out of the dotfiles into a standalone plugin once v1 has worked well for a while.
