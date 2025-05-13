local M = {}
local fs = require("pytest.fs")

function M.pytest_ini_exists()
  return fs.file_exists("pytest.ini")
end

function M.pyproject_toml_exists()
  return fs.file_exists("pyproject.toml")
end

function M.pyproject_toml_lists_pytest()
  if not M.pyproject_toml_exists() then return false end
  local content = fs.read_file("pyproject.toml")
  if not content then return false end

  local sections = {
    "[tool.poetry.dependencies]",
    "[tool.poetry.dev-dependencies]",
    "[tool.pdm.dependencies]",
    "[tool.pdm.dev-dependencies]",
    "[tool.flit.metadata.requires]",
    "[tool.flit.metadata.requires-extra]",
    "[project.dependencies]",
    "[project.optional-dependencies]",
  }

  for _, section in ipairs(sections) do
    if content:match(section) then
      local section_content = content:match(section .. "(.-)%[") or content:match(section .. "(.-)$")
      if section_content and section_content:match("pytest") then
        return true
      end
    end
  end

  return false
end

function M.requirements_txt_lists_pytest()
  return fs.file_contains("requirements.txt", "pytest")
end

function M.setup_cfg_lists_pytest()
  return fs.file_contains("setup.cfg", "[tool:pytest]")
end

function M.has_test_files()
  local test_files = vim.fn.glob("**/test_*.py", false, true)
  return test_files and #test_files > 0
end

function M.pyproject_toml_contains_pytest()
  if not M.pyproject_toml_exists() then return false end
  local content = fs.read_file("pyproject.toml")
  if not content then return false end
  return content:match("%[tool%.pytest%]") or content:match("%[tool%.pytest%.ini_options%]")
end

function M.should_load_plugin()
  return M.pytest_ini_exists()
    or M.pyproject_toml_contains_pytest()
    or M.pyproject_toml_lists_pytest()
    or M.requirements_txt_lists_pytest()
    or M.setup_cfg_lists_pytest()
    or M.has_test_files()
end

return M
