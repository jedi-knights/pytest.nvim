local config = require("pytest.config")

local M = {}

-- Expose this so you can test it with Busted
function M.build_command(file)
  local opts = config.options
  local cmd = { opts.python_command, "-m", "pytest" }

  -- Add extra args
  vim.list_extend(cmd, opts.pytest_args)

  -- Add the file
  if file then
    table.insert(cmd, file)
  end

  return cmd
end

function M.run_file()
  local file = vim.fn.expand("%")
  local cmd = M.build_command(file)
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.fn.setqflist({}, ' ', {title = 'Pytest Results', lines = data})
        vim.cmd("copen")
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.notify(table.concat(data, "\n"), vim.log.levels.ERROR)
      end
    end,
  })
end

function M.run_all(opts)
  opts = opts or {}
  local cmd = M.build_command()

  -- Add markers if provided
  if opts.markers then
    table.insert(cmd, "-m")
    table.insert(cmd, opts.markers)
  end

  -- Build env table
  local env_tbl = {}
  if opts.env_vars then
    -- If env_vars were provided from UI, use them
    for key, val in pairs(opts.env_vars) do
      table.insert(env_tbl, string.format("%s=%s", key, val))
    end
  else
    -- Otherwise, use defaults (first values in each envs table)
    local envs = require("pytest.config").options.envs or {}
    for key, values in pairs(envs) do
      if #values > 0 then
        table.insert(env_tbl, string.format("%s=%s", key, values[1]))
      end
    end
  end

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    env = env_tbl,
    on_stdout = function(_, data)
      if data then
        vim.fn.setqflist({}, ' ', { title = 'Pytest Results', lines = data })
        vim.cmd("copen")
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.notify(table.concat(data, "\n"), vim.log.levels.ERROR)
      end
    end,
  })
end


function M.run_nearest()
  vim.notify("run_nearest not implemented yet", vim.log.levels.WARN)
end

return M
