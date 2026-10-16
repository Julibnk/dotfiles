-- Syncs diffview-plus file marks with the Viewed checkboxes of a GitHub PR.
local github = require("diffview-pr.github")
local store = require("diffview-pr.store")

local M = {}

local FLUSH_DELAY_MS = 1000

---@class diffview_pr.Session
---@field pr diffview_pr.Pr
---@field read_only boolean True when local HEAD differs from the PR head.
---@field gh_states? table<string, diffview_pr.ViewedState> Nil when GitHub could not be reached.
---@field viewed table<string, true>
---@field marks_head string PR head the `viewed` marks belong to.
---@field pending table<string, boolean>
---@field loaded boolean True once the file list has loaded and the marks are applied.
---@field applying_marks boolean True while the module changes the panel marks itself.
---@field flush_token integer

---@type table<DiffView, diffview_pr.Session>
local sessions = {}
local listeners_added = false

local open_pr_view, apply_state, show_marks, add_listeners, handle_selection_change, schedule_flush, flush_pending
local save_session, list_viewed, count_viewed, find_current_session, warn_read_only, notify, start_progress, await
local make_set

---@class diffview_pr.Progress
---@field report fun(message: string)
---@field finish fun()

function M.setup()
  vim.api.nvim_create_user_command("DiffviewPR", function(opts)
    M.open(tonumber(opts.args))
  end, { nargs = "?", desc = "Review the PR of this branch, or check out and review PR <number>" })
  vim.api.nvim_create_user_command("DiffviewPRSync", M.sync, { desc = "Sync file marks with the GitHub PR" })
end

---Open a diffview of the PR and sync its file marks with GitHub.
---@param number integer? PR to check out first; nil uses the current branch.
function M.open(number)
  local progress = start_progress(number and ("Loading PR #%d"):format(number) or "Loading PR")
  coroutine.wrap(function()
    if number then
      progress.report("Checking out the branch")
      local err = await(github.checkout_pr, number)
      if err then
        progress.finish()
        return notify("Checkout failed: " .. err, vim.log.levels.ERROR)
      end
    end

    progress.report("Finding the PR")
    local pr_err, pr = await(github.find_pr, number)
    if pr_err or not pr then
      progress.finish()
      return notify("No PR found: " .. tostring(pr_err), vim.log.levels.ERROR)
    end
    progress.report(("Fetching origin/%s"):format(pr.base))
    local fetch_err = await(github.fetch_branch, pr.base)
    if fetch_err then
      notify(("Could not fetch origin/%s, using the local copy: %s"):format(pr.base, fetch_err), vim.log.levels.WARN)
    end
    local _, head = await(github.get_head_sha)
    progress.report("Reading viewed files from GitHub")
    local gh_err, gh_states = await(github.get_viewed_states, pr.id)
    if gh_err then
      notify("GitHub unreachable, using local marks: " .. gh_err, vim.log.levels.WARN)
    end

    progress.report("Opening the diff")
    open_pr_view(pr, head ~= pr.head_sha, gh_states, progress)
  end)()
end

---Check the PR head again, pull the GitHub state and send pending writes for the current PR view.
function M.sync()
  local view, session = find_current_session()
  if not view or not session then
    return notify("Not a PR view. Open one with :DiffviewPR", vim.log.levels.WARN)
  end
  local progress = start_progress(("Syncing PR #%d"):format(session.pr.number))
  coroutine.wrap(function()
    progress.report("Checking the PR head")
    local pr_err, pr = await(github.find_pr, session.pr.number)
    if pr_err or not pr then
      progress.finish()
      return notify("Could not read the PR: " .. tostring(pr_err), vim.log.levels.WARN)
    end
    local _, head = await(github.get_head_sha)
    progress.report("Reading viewed files from GitHub")
    local err, gh_states = await(github.get_viewed_states, pr.id)
    progress.finish()
    if err then
      return notify("GitHub unreachable, keeping local marks: " .. err, vim.log.levels.WARN)
    end

    session.pr = pr
    session.read_only = head ~= pr.head_sha
    apply_state(view, session, gh_states)
  end)()
end

---Clear all marks, except in PR views where that would unmark the whole PR on GitHub.
function M.clear_selections()
  local _, session = find_current_session()
  if session then
    return notify("Clearing all marks is disabled in PR views", vim.log.levels.WARN)
  end
  require("diffview.actions").clear_select_entries()
end

---@alias diffview_pr.ViewedState "VIEWED"|"UNVIEWED"|"DISMISSED"

---@class diffview_pr.Entry
---@field head_sha string PR head the marks belong to.
---@field viewed string[] Marked paths, including files the PR does not have.
---@field pending table<string, boolean> Writes GitHub has not confirmed: true marks, false unmarks.
---@field updated_at? integer

---@class diffview_pr.ReconcileInput
---@field head_sha string Current PR head.
---@field gh_states? table<string, diffview_pr.ViewedState> Nil when GitHub could not be reached.
---@field entry? diffview_pr.Entry

---Merge the GitHub state with the local entry into the marks to show and the writes to send.
---@param input diffview_pr.ReconcileInput
---@return { viewed: string[], writes: table<string, boolean> }
function M.reconcile(input)
  local gh_states = input.gh_states
  local entry = input.entry
  local marked = {}

  for path, state in pairs(gh_states or {}) do
    if state == "VIEWED" then
      marked[path] = true
    end
  end
  if entry and entry.head_sha == input.head_sha then
    for _, path in ipairs(entry.viewed) do
      if not gh_states or gh_states[path] == nil then
        marked[path] = true
      end
    end
  end

  local writes = {}
  for path, value in pairs(entry and entry.pending or {}) do
    marked[path] = value or nil
    local gh_state = gh_states and gh_states[path]
    if not gh_states or (gh_state ~= nil and (gh_state == "VIEWED") ~= value) then
      writes[path] = value
    end
  end

  local viewed = vim.tbl_keys(marked)
  table.sort(viewed)
  return { viewed = viewed, writes = writes }
end

---@param pr diffview_pr.Pr
---@param read_only boolean
---@param gh_states? table<string, diffview_pr.ViewedState>
---@param progress diffview_pr.Progress Finished once the marks are on the panel.
function open_pr_view(pr, read_only, gh_states, progress)
  vim.cmd({ cmd = "DiffviewOpen", args = { ("origin/%s...HEAD"):format(pr.base), "--imply-local" } })
  local view = require("diffview.lib").get_current_view() --[[@as DiffView?]]
  if not view then
    progress.finish()
    return notify("Diffview did not open", vim.log.levels.ERROR)
  end
  add_listeners()

  local entry = store.load(pr.key)
  ---@type diffview_pr.Session
  local session = {
    pr = pr,
    read_only = read_only,
    viewed = make_set(entry and entry.viewed or {}),
    marks_head = entry and entry.head_sha or pr.head_sha,
    pending = entry and entry.pending or {},
    loaded = false,
    applying_marks = false,
    flush_token = 0,
  }
  sessions[view] = session

  -- The file list loads async, and each refresh can bring back files whose marks the panel dropped.
  view.emitter:on("files_updated", function()
    if session.loaded then
      return show_marks(view, session)
    end
    session.loaded = true
    progress.finish()
    apply_state(view, session, gh_states)
  end)
end

---Reconcile the session with the GitHub state, show the result and send the remaining writes.
---@param view DiffView
---@param session diffview_pr.Session
---@param gh_states? table<string, diffview_pr.ViewedState>
function apply_state(view, session, gh_states)
  local result = M.reconcile({
    head_sha = session.pr.head_sha,
    gh_states = gh_states,
    entry = { head_sha = session.marks_head, viewed = list_viewed(session), pending = session.pending },
  })
  session.gh_states = gh_states
  session.viewed = make_set(result.viewed)
  session.marks_head = session.pr.head_sha
  session.pending = result.writes

  show_marks(view, session)
  save_session(session)
  if gh_states then
    notify(("PR #%d synced · %d/%d viewed"):format(session.pr.number, count_viewed(session), vim.tbl_count(gh_states)))
  end
  if session.read_only then
    warn_read_only(session.pr)
  end
  flush_pending(session)
end

---Make the panel marks match the session and redraw the panel.
---@param view DiffView
---@param session diffview_pr.Session
function show_marks(view, session)
  session.applying_marks = true
  require("diffview.api.selections").set(list_viewed(session), { view = view })
  session.applying_marks = false
  view.panel:render()
  view.panel:redraw()
end

function add_listeners()
  if listeners_added then
    return
  end
  listeners_added = true
  DiffviewGlobal.emitter:on("selection_changed", function(_, view)
    handle_selection_change(view)
  end)
  DiffviewGlobal.emitter:on("view_closed", function(_, view)
    local session = sessions[view]
    sessions[view] = nil
    if session then
      flush_pending(session)
    end
  end)
end

---Turn a user mark or unmark into a pending write.
---@param view DiffView
function handle_selection_change(view)
  local session = sessions[view]
  if not session or not session.loaded or session.applying_marks then
    return
  end
  local selected = make_set(require("diffview.api.selections").get_paths(view))
  local changed = false
  -- Only paths still in the file list count: the panel also drops marks of vanished files.
  for _, file in view.files:iter() do
    local path = file.path
    local is_selected = selected[path] == true
    if (session.viewed[path] == true) ~= is_selected then
      session.viewed[path] = is_selected or nil
      changed = true
      -- Without GitHub states every change waits in pending; reconcile later drops the non-PR ones.
      if not session.read_only and (not session.gh_states or session.gh_states[path]) then
        session.pending[path] = is_selected
      end
    end
  end
  if changed then
    save_session(session)
    schedule_flush(session)
  end
end

---Send pending writes once marks stop changing for a moment.
---@param session diffview_pr.Session
function schedule_flush(session)
  session.flush_token = session.flush_token + 1
  local token = session.flush_token
  vim.defer_fn(function()
    if session.flush_token == token then
      flush_pending(session)
    end
  end, FLUSH_DELAY_MS)
end

---Send every pending write to GitHub and drop the ones it confirms.
---Nothing is sent in read-only mode, or before GitHub states are known.
---@param session diffview_pr.Session
function flush_pending(session)
  if session.read_only or not session.gh_states then
    return
  end
  local writes = vim.deepcopy(session.pending)
  local remaining = vim.tbl_count(writes)
  local failures = {}
  for path, value in pairs(writes) do
    github.set_viewed(session.pr.id, path, value, function(err)
      if err then
        failures[#failures + 1] = path
      elseif session.pending[path] == value then
        session.pending[path] = nil
      end
      remaining = remaining - 1
      if remaining == 0 then
        save_session(session)
        if #failures > 0 then
          notify(("Could not sync %d file(s) with GitHub, will retry on next sync: %s"):format(
            #failures, table.concat(failures, ", ")), vim.log.levels.ERROR)
        end
      end
    end)
  end
end

---@param session diffview_pr.Session
function save_session(session)
  store.save(session.pr.key, { head_sha = session.marks_head, viewed = list_viewed(session), pending = session.pending })
end

---@param session diffview_pr.Session
---@return string[]
function list_viewed(session)
  local viewed = vim.tbl_keys(session.viewed)
  table.sort(viewed)
  return viewed
end

---Count the marked files that are part of the PR.
---@param session diffview_pr.Session
---@return integer
function count_viewed(session)
  local count = 0
  for path in pairs(session.viewed) do
    if session.gh_states[path] then
      count = count + 1
    end
  end
  return count
end

---@return DiffView? view
---@return diffview_pr.Session? session
function find_current_session()
  local view = require("diffview.lib").get_current_view() --[[@as DiffView?]]
  return view, view and sessions[view]
end

---@param pr diffview_pr.Pr
function warn_read_only(pr)
  notify(("PR #%d read-only: local HEAD differs from the PR head. Pull or check out to sync."):format(pr.number),
    vim.log.levels.WARN)
end

---@param msg string
---@param level? integer
function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "diffview-pr" })
end

---Show a progress spinner through fidget, or a single message when fidget is missing.
---@param title string
---@return diffview_pr.Progress
function start_progress(title)
  local ok, fidget_progress = pcall(require, "fidget.progress")
  if not ok then
    notify(title .. "…")
    return { report = function() end, finish = function() end }
  end
  local handle = fidget_progress.handle.create({ title = title, lsp_client = { name = "diffview-pr" } })
  return {
    report = function(message)
      handle:report({ message = message })
    end,
    finish = function()
      handle:finish()
    end,
  }
end

---Call `fn(..., callback)` from inside a coroutine and return the callback's arguments.
---@param fn function
---@return ...
function await(fn, ...)
  local co = coroutine.running()
  local args = { n = select("#", ...), ... }
  args[args.n + 1] = function(...)
    local ok, err = coroutine.resume(co, ...)
    if not ok then
      error(err)
    end
  end
  fn(unpack(args, 1, args.n + 1))
  return coroutine.yield()
end

---@param list string[]
---@return table<string, true>
function make_set(list)
  local set = {}
  for _, item in ipairs(list) do
    set[item] = true
  end
  return set
end

return M
