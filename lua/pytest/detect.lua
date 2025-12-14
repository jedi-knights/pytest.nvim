local M = {}
local fs = require("pytest.fs")

local _detect_cache = setmetatable({}, { __mode = "kv" })

local function get_file_cache_key(filepath)
  local stat = vim.loop.fs_stat(filepath)
  if not stat then
    return nil
  end
  return filepath .. ":" .. stat.mtime.sec .. ":" .. stat.size
end

local function cached_check(key, check_fn)
  if _detect_cache[key] ~= nil then
    return _detect_cache[key]
  end
  local result = check_fn()
  _detect_cache[key] = result
  return result
end

function M.pytest_ini_exists()
  return cached_check("pytest_ini", function()
    return fs.file_exists("pytest.ini")
  end)
end

function M.pyproject_toml_exists()
  return cached_check("pyproject_toml", function()
    return fs.file_exists("pyproject.toml")
  end)
end

function M.pyproject_toml_lists_pytest()
  local cache_key = get_file_cache_key("pyproject.toml")
  if not cache_key then
    return false
  end

  return cached_check("pyproject_lists:" .. cache_key, function()
    if not M.pyproject_toml_exists() then return false end

    local content = fs.read_file("pyproject.toml")
    if not content then return false end

    return content:match("%[tool%.pytest%]") ~= nil
  end)
end

function M.requirements_txt_lists_pytest()
  return cached_check("requirements_pytest", function()
    return fs.file_contains("requirements.txt", "pytest")
  end)
end


function M.setup_cfg_lists_pytest()
  local cache_key = get_file_cache_key("setup.cfg")
  if not cache_key then
    return cached_check("setup_cfg_missing", function() return false end)
  end

  return cached_check("setup_cfg:" .. cache_key, function()
    if not fs.file_exists("setup.cfg") then return false end

    local content = fs.read_file("setup.cfg")
    if not content then return false end

    local pytest_detected = false
    local in_section = nil

    for line in content:gmatch("[^\r\n]+") do
      local clean_line = line:gsub("#.*", ""):gsub("^%s*", ""):gsub("%s*$", "")

      local section = clean_line:match("^%[([^%]]+)%]")
      if section then
        in_section = section
      elseif in_section then
        if in_section == "tool:pytest" then
          return true
        elseif
          in_section == "options.extras_require" or
          in_section == "options.setup_requires" or
          in_section == "options.tests_require" or
          in_section == "options"
        then
          if clean_line:match("['\"]?pytest['\"]?") then
            pytest_detected = true
          end
        end
      end
    end

    return pytest_detected
  end)
end

function M.has_test_files()
  return cached_check("test_files:" .. vim.fn.getcwd(), function()
    local test_files = vim.fn.glob("**/test_*.py", false, true)
    return test_files and #test_files > 0
  end)
end

function M.pyproject_toml_contains_pytest()
  local cache_key = get_file_cache_key("pyproject.toml")
  if not cache_key then
    return false
  end

  return cached_check("pyproject_contains:" .. cache_key, function()
    if not M.pyproject_toml_exists() then return false end
    local content = fs.read_file("pyproject.toml")
    if not content then return false end
    return content:match("%[tool%.pytest%]") ~= nil 
          or content:match("%[tool%.pytest%.ini_options%]") ~= nil
  end)
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

function M.clear_cache()
  _detect_cache = setmetatable({}, { __mode = "kv" })
end

return M
