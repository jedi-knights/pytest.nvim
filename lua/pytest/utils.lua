-- pytest.nvim/lua/pytest/utils.lua
local M = {}

---
-- Reads the contents of a file and returns it as a string.
-- @param path (string) The path to the file
-- @return (string|nil) The file contents, or nil if not readable
function M.read_file(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  return content
end

return M 