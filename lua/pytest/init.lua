local M = {}


--- Setup the plugin with user options
-- @param user_opts table: user configuration table
function M.setup(opts)
    print("Options: " .. vim.inspect(opts))
end

--- Run pytest for the current file
function M.run_file()
    local file = vim.fn.expand("%:p")
    local cmd = "pytest " .. file
    vim.cmd("terminal " .. cmd)
end

--- Run all pytest tests in the project
function M.run_all()
    local cmd = "pytest"
    vim.cmd("terminal " .. cmd)
end

--- Run the nearest test (TODO: not yet implemented)
function M.run_nearest()
    local file = vim.fn.expand("%:p")
    local cmd = "pytest " .. file .. " -k 'nearest_test'"
    vim.cmd("terminal " .. cmd)
end

return M

