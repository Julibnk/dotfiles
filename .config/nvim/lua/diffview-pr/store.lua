-- Local JSON store of PR marks, keyed by `owner/repo#number`.
local M = {}

local MAX_AGE_SECONDS = 30 * 24 * 60 * 60

local get_path, read_store, write_store, prune_old_entries, notify

---@return string
function get_path()
  return vim.fn.stdpath("data") .. "/diffview_pr.json"
end

---@param key string
---@return diffview_pr.Entry?
function M.load(key)
  return read_store(get_path())[key]
end

---Save an entry and drop entries untouched for 30 days, unless they have pending writes.
---@param key string
---@param entry diffview_pr.Entry
function M.save(key, entry)
  local path = get_path()
  local store = read_store(path)
  entry.updated_at = os.time()
  store[key] = entry
  prune_old_entries(store)
  write_store(path, store)
end

---@param path string
---@return table<string, diffview_pr.Entry>
function read_store(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok or #lines == 0 then
    return {}
  end
  local decode_ok, data = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not decode_ok or type(data) ~= "table" then
    notify("Ignoring corrupt store " .. path, vim.log.levels.WARN)
    return {}
  end
  return data
end

---Write the store atomically through a temp file and a rename.
---@param path string
---@param data table
function write_store(path, data)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local tmp = path .. ".tmp"
  if vim.fn.writefile({ vim.json.encode(data) }, tmp) ~= 0 then
    notify("Could not write " .. tmp, vim.log.levels.ERROR)
    return
  end
  local ok, err = vim.uv.fs_rename(tmp, path)
  if not ok then
    notify("Could not save the store: " .. tostring(err), vim.log.levels.ERROR)
  end
end

---@param store table<string, diffview_pr.Entry>
function prune_old_entries(store)
  local cutoff = os.time() - MAX_AGE_SECONDS
  for key, entry in pairs(store) do
    if (entry.updated_at or 0) < cutoff and next(entry.pending or {}) == nil then
      store[key] = nil
    end
  end
end

---@param msg string
---@param level integer
function notify(msg, level)
  vim.notify(msg, level, { title = "diffview-pr" })
end

return M
