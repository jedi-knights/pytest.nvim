local M = {}

local config = require("pytest.config")
local runner = require("pytest.runner")
local ui = require("pytest.ui")

--- Setup the plugin with user options
-- @param user_opts table: user configuration table
function M.setup(user_opts)
  config.setup(user_opts)
end

--- Run pytest for the current file
function M.run_file()
  runner.run_file()
end

--- Run all pytest tests in the project
function M.run_all()
  runner.run_all()
end

--- Run the nearest test (TODO: not yet implemented)
function M.run_nearest()
  runner.run_nearest()
end

--- Launch the interactive Telescope UI to select env + markers
function M.run_with_ui()
  ui.run_with_ui()
end

return M
