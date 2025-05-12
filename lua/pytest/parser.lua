local M = {}

function M.parse_ini(content)
    local config = {}
    local in_pytest_section = false

    for line in content:gmatch("[^\r\n]+") do
        line = line:match("^%s*(.-)%s*$")
        if line:match("^%[.*%]$") then
            in_pytest_section = line:lower() == "[pytest]"
        elseif in_pytest_section and line ~= "" and not line:match("^;") and not line:match("^#") then
            local key, value = line:match("^(.-)%s*=%s*(.*)$")
            if key and value then config[key] = value end
        end
    end

    return config
end

function M.parse_toml(content)
    local config = {}
    local in_pytest_section = false

    for line in content:gmatch("[^\r\n]+") do
        line = line:match("^%s*(.-)%s*$")
        if line:lower() == "[tool.pytest.ini_options]" then
            in_pytest_section = true
        elseif line:match("^%[.*%]$") then
            in_pytest_section = false
        elseif in_pytest_section and line ~= "" and not line:match("^#") then
            local key, value = line:match("^(.-)%s*=%s*(.*)$")
            if key and value then config[key] = value end
        end
    end

    return config
end

return M
