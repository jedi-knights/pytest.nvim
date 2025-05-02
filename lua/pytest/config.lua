local M = {}

M.options = {
  python_command = "python3",
  pytest_args = {"-v"},
  markers = {},
  envs = {},
}

function M.setup(user_opts)
  M.options = vim.tbl_deep_extend("force", M.options, user_opts or {})
end

return M

