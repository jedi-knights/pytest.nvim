local M = {}
local fs = require("pytest.fs")

function M.should_load_plugin()
  return M.pytest_ini_exists() or M.pyproject_toml_contains_pytest()
end

function M.pytest_ini_exists()
  return fs.file_exists("pytest.ini")
end

function M.pyproject_toml_exists()
  return fs.file_exists("pyproject.toml")
end

function M.pyproject_toml_contains_pytest()
  if not M.pyproject_toml_exists() then return false end
  local content = fs.read_file("pyproject.toml")
  if not content then return false end
  return content:match("%[tool%.pytest%]") or content:match("%[tool%.pytest%.ini_options%]")
end

return M
