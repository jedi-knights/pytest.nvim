local M = {}

local config = require("pytest.config")
local runner = require("pytest.runner")

function M.setup(user_opts)
  config.setup(user_opts)
end

function M.run_file()
  runner.run_file()
end

function M.run_all()
  runner.run_all()
end

function M.run_nearest()
  runner.run_nearest()
end

return M

