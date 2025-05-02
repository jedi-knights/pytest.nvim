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

function M.run_all()
  local cmd = M.build_command()
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

function M.run_nearest()
  vim.notify("run_nearest not implemented yet", vim.log.levels.WARN)
end

return M
