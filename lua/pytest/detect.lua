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

    -- Match [tool.pytest] section directly
    return content:match("%[tool%.pytest%]") ~= nil
end

function M.requirements_txt_lists_pytest()
  return fs.file_contains("requirements.txt", "pytest")
end


function M.setup_cfg_lists_pytest()
  if not fs.file_exists("setup.cfg") then return false end

  local content = fs.read_file("setup.cfg")
  if not content then return false end

  local pytest_detected = false
  local in_section = nil

  for line in content:gmatch("[^\r\n]+") do
    -- Strip comments and trim
    local clean_line = line:gsub("#.*", ""):gsub("^%s*", ""):gsub("%s*$", "")

    -- Detect section headers
    local section = clean_line:match("^%[([^%]]+)%]")
    if section then
      in_section = section
    elseif in_section then
      if in_section == "tool:pytest" then
        -- Presence of this section implies pytest is used
        return true
      elseif
        in_section == "options.extras_require" or
        in_section == "options.setup_requires" or
        in_section == "options.tests_require" or
        in_section == "options"
      then
        -- Detect explicit "pytest" mention in these sections
        if clean_line:match("['\"]?pytest['\"]?") then
          pytest_detected = true
        end
      end
    end
  end

  return pytest_detected
end

function M.has_test_files()
  local test_files = vim.fn.glob("**/test_*.py", false, true)
  return test_files and #test_files > 0
end

function M.pyproject_toml_contains_pytest()
  if not M.pyproject_toml_exists() then return false end
  local content = fs.read_file("pyproject.toml")
  if not content then return false end
  return content:match("%[tool%.pytest%]") ~= nil 
        or content:match("%[tool%.pytest%.ini_options%]") ~= nil
end

function M.debug()
  print("[pytest.nvim] Debugging plugin load conditions:")

  local results = {
    ["pytest.ini"] = M.pytest_ini_exists(),
    ["pyproject.toml [tool.pytest]"] = M.pyproject_toml_contains_pytest(),
    ["pyproject.toml dependency"] = M.pyproject_toml_lists_pytest(),
    ["requirements.txt"] = fs.file_contains("requirements.txt", "pytest"),
    ["setup.cfg"] = fs.file_contains("setup.cfg", "[tool:pytest]"),
    ["test files found"] = M.has_test_files(),
  }

  for label, result in pairs(results) do
    print(string.format("  %-30s: %s", label, result and "✅" or "❌"))
  end
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
