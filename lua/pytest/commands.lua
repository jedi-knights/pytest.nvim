-- lua/pytest/commands.lua
local M = {}
local config = require("pytest.config")
local should_load_plugin = require("pytest.detect").should_load_plugin

function M.start()
    if not should_load_plugin() then
        vim.notify("Pytest plugin not loaded: condition not met", vim.log.levels.WARN)
        return
    end

    local cfg = config.load_config()
    if not cfg then
        vim.notify("Could not load pytest config", vim.log.levels.ERROR)
        return
    end

    -- Example: use environments and regions
    vim.notify("Loaded environments: " .. table.concat(cfg.environments or {}, ", "), vim.log.levels.INFO)
    vim.notify("Loaded regions: " .. table.concat(cfg.regions or {}, ", "), vim.log.levels.INFO)

    -- Call the setup function with the specified config
    core.setup(cfg)
end

return M

