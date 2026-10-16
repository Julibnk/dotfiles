-- Thin async wrappers over the gh and git CLIs. Every callback runs on the main loop.
local M = {}

local MAX_ATTEMPTS = 3
local RETRY_DELAY_MS = 1000
local NETWORK_ERROR_PATTERNS = {
  "timeout",
  "tls handshake",
  "connection reset",
  "connection refused",
  "unexpected eof",
  "could not resolve host",
  "temporary failure in name resolution",
}

local run_command, is_network_error

---@class diffview_pr.Pr
---@field id string GraphQL node ID.
---@field number integer
---@field key string Store key, `owner/repo#number`.
---@field head_sha string
---@field base string Base branch name.

local VIEWED_STATES_QUERY = [[
query($id: ID!, $endCursor: String) {
  node(id: $id) {
    ... on PullRequest {
      files(first: 100, after: $endCursor) {
        nodes { path viewerViewedState }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
}]]

local SET_VIEWED_MUTATION = [[
mutation($id: ID!, $path: String!) {
  %s(input: { pullRequestId: $id, path: $path }) { clientMutationId }
}]]

---Look up the PR for the current branch, or the given number.
---@param number integer?
---@param callback fun(err: string?, pr: diffview_pr.Pr?)
function M.find_pr(number, callback)
  local cmd = { "gh", "pr", "view", "--json", "id,number,url,headRefOid,baseRefName" }
  if number then
    table.insert(cmd, 4, tostring(number))
  end
  run_command(cmd, function(err, stdout)
    if err then
      return callback(err)
    end
    local data = vim.json.decode(stdout)
    local repo = data.url:match("^https?://[^/]+/([^/]+/[^/]+)/pull/")
    callback(nil, {
      id = data.id,
      number = data.number,
      key = ("%s#%d"):format(repo, data.number),
      head_sha = data.headRefOid,
      base = data.baseRefName,
    })
  end)
end

---@param number integer
---@param callback fun(err: string?)
function M.checkout_pr(number, callback)
  run_command({ "gh", "pr", "checkout", tostring(number) }, callback)
end

---Read the viewed state of every file in the PR.
---@param pr_id string
---@param callback fun(err: string?, files: table<string, diffview_pr.ViewedState>?)
function M.get_viewed_states(pr_id, callback)
  local cmd = { "gh", "api", "graphql", "--paginate", "--slurp", "-f", "query=" .. VIEWED_STATES_QUERY, "-f", "id=" .. pr_id }
  run_command(cmd, function(err, stdout)
    if err then
      return callback(err)
    end
    local files = {}
    for _, page in ipairs(vim.json.decode(stdout)) do
      for _, file in ipairs(page.data.node.files.nodes) do
        files[file.path] = file.viewerViewedState
      end
    end
    callback(nil, files)
  end)
end

---Tick or untick the Viewed checkbox of one file.
---@param pr_id string
---@param path string
---@param viewed boolean
---@param callback fun(err: string?)
function M.set_viewed(pr_id, path, viewed, callback)
  local mutation = SET_VIEWED_MUTATION:format(viewed and "markFileAsViewed" or "unmarkFileAsViewed")
  run_command({ "gh", "api", "graphql", "-f", "query=" .. mutation, "-f", "id=" .. pr_id, "-f", "path=" .. path }, callback)
end

---@param branch string
---@param callback fun(err: string?)
function M.fetch_branch(branch, callback)
  run_command({ "git", "fetch", "origin", branch }, callback)
end

---@param callback fun(err: string?, sha: string?)
function M.get_head_sha(callback)
  run_command({ "git", "rev-parse", "HEAD" }, function(err, stdout)
    callback(err, stdout and vim.trim(stdout))
  end)
end

---Run a command and pass its stdout, or its stderr as the error, to the callback.
---Network errors are retried a few times, since every command here is safe to repeat.
---@param cmd string[]
---@param callback fun(err: string?, stdout: string?)
---@param attempt? integer
function run_command(cmd, callback, attempt)
  attempt = attempt or 1
  local ok, err = pcall(vim.system, cmd, { text = true }, vim.schedule_wrap(function(result)
    if result.code ~= 0 then
      local message = vim.trim(result.stderr ~= "" and result.stderr or result.stdout)
      if attempt < MAX_ATTEMPTS and is_network_error(message) then
        return vim.defer_fn(function()
          run_command(cmd, callback, attempt + 1)
        end, RETRY_DELAY_MS)
      end
      return callback(message)
    end
    callback(nil, result.stdout)
  end))
  if not ok then
    vim.schedule(function()
      callback(tostring(err))
    end)
  end
end

---@param message string
---@return boolean
function is_network_error(message)
  local lower = message:lower()
  for _, pattern in ipairs(NETWORK_ERROR_PATTERNS) do
    if lower:find(pattern, 1, true) then
      return true
    end
  end
  return false
end

return M
