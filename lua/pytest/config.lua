-- lua/pytest/config.lua
local M = {}

function M.load_config()
    local path = vim.fn.getcwd() .. "/.pytest.cfg.json"
    if vim.fn.filereadable(path) ~= 1 then
        return nil
    end

    local file = io.open(path, "r")
    if not file then return nil end

    local content = file:read("*a")
    file:close()

    local ok, decoded = pcall(vim.json_decode, content)
    if not ok then
        vim.notify("Failed to decode JSON: " .. decoded, vim.log.levels.ERROR)
        return nil
    end

    return decoded
end

return M

