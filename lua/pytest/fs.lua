local M = {}

function M.read_file(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  return content
end

function M.file_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == "file"
end

function M.dir_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == "directory"
end

function M.file_contains(path, pattern)
  if not M.file_exists(path) then return false end
  local content = M.read_file(path)
  return content and content:match(pattern)
end

return M
