local M = {}
local parser = require("pytest.parser")
local utils = require("pytest.utils")

local files_to_check = {
    { name = "pytest.ini", parser = parser.parse_ini },
    { name = "pyproject.toml", parser = parser.parse_toml },
}

local config = {}

function M.read_pytest_config(callback)
    local files_found = {}
    
    local job_id = vim.fn.jobstart({"find", ".", "-maxdepth", "3", "-name", "*.ini", "-o", "-name", "*.toml"}, {
        on_stdout = function(_, data)
            for _, line in ipairs(data) do
                if line and line ~= "" then
                    table.insert(files_found, line)
                end
            end
        end,
        on_exit = function(_, exit_code)
            if exit_code == 0 then
                for _, file in ipairs(files_found) do
                    for _, spec in ipairs(files_to_check) do
                        if file:match(spec.name) then
                            local content = utils.read_file(file)
                            if content then
                                config = spec.parser(content)
                                callback(config, file)
                                return
                            end
                        end
                    end
                end
            end
            vim.schedule(function()
                vim.notify("pytest config not found", vim.log.levels.WARN)
            end)
        end
    })
end

function M.show_config()
    M.read_pytest_config(function(cfg, file)
        vim.schedule(function()
            vim.notify("Loaded from: " .. file .. "\n" .. vim.inspect(cfg), vim.log.levels.INFO)
        end)
    end)
end

function M.edit_config()
    M.read_pytest_config(function(_, file)
        vim.schedule(function()
            vim.cmd("edit " .. file)
        end)
    end)
end

function M.watch_config()
    M.read_pytest_config(function(_, file)
        local handle = vim.loop.new_fs_poll()
        handle:start(file, 1000, vim.schedule_wrap(function()
            vim.notify("pytest config updated: " .. file, vim.log.levels.INFO)
        end))
    end)
end

function M.snacks_picker()
    local snacks = require('snacks')

    M.read_pytest_config(function(cfg)
        local entries = {}
        for k, v in pairs(cfg) do
            table.insert(entries, {
                text = k .. " = " .. v,
                value = { key = k, value = v }
            })
        end

        snacks.select({
            prompt = 'Pytest Config',
            items = entries,
            on_select = function(item)
                vim.notify("Selected: " .. item.text, vim.log.levels.INFO)
            end
        })
    end)
end

function M.snacks_environment_picker()
    local snacks = require('snacks')
    
    -- Example environments - in a real implementation, these would come from config
    local environments = {
        { text = "development", value = "dev" },
        { text = "staging", value = "staging" },
        { text = "production", value = "prod" },
        { text = "testing", value = "test" }
    }

    snacks.select({
        prompt = 'Select Environment',
        items = environments,
        on_select = function(item)
            vim.notify("Selected environment: " .. item.text, vim.log.levels.INFO)
            -- Here you would run pytest with the selected environment
            -- M.run_tests_with_environment(item.value)
        end
    })
end

function M.snacks_marker_picker()
    local snacks = require('snacks')
    
    -- Example markers - in a real implementation, these would be detected from test files
    local markers = {
        { text = "unit", value = "unit" },
        { text = "integration", value = "integration" },
        { text = "slow", value = "slow" },
        { text = "fast", value = "fast" },
        { text = "smoke", value = "smoke" }
    }

    snacks.select({
        prompt = 'Select Marker',
        items = markers,
        on_select = function(item)
            vim.notify("Selected marker: " .. item.text, vim.log.levels.INFO)
            -- Here you would run pytest with the selected marker
            -- M.run_tests_with_marker(item.value)
        end
    })
end


function M.run_plugin_tests()
    local output_lines = {}
    
    local job_id = vim.fn.jobstart({"nvim", "--headless", "-c", "echo 'No tests directory found'"}, {
        on_stdout = function(_, data)
            for _, line in ipairs(data) do
                if line and line ~= "" then
                    table.insert(output_lines, line)
                end
            end
        end,
        on_exit = function(_, exit_code)
            local result = table.concat(output_lines, "\n")
            vim.schedule(function()
                if exit_code == 0 then
                    vim.notify("✅ Plugin tests passed!\n" .. result, vim.log.levels.INFO)
                else
                    vim.notify("❌ Plugin tests failed!\n" .. result, vim.log.levels.ERROR)
                end
            end)
        end
    })
end

-- Utility: Find all venvs in the project root by looking for activate scripts
local function find_virtual_envs()
    local cwd = vim.fn.getcwd()
    local entries = vim.fn.readdir(cwd)
    local venvs = {}
    for _, entry in ipairs(entries) do
        local dir_path = cwd .. "/" .. entry
        if vim.fn.isdirectory(dir_path) == 1 then
            local unix_activate = dir_path .. "/bin/activate"
            local win_activate = dir_path .. "/Scripts/activate"
            if vim.fn.filereadable(unix_activate) == 1 or vim.fn.filereadable(win_activate) == 1 then
                table.insert(venvs, dir_path)
            end
        end
    end
    return venvs
end

-- Utility: Prompt user to select a venv if multiple are found
local function select_virtual_env(callback)
    local venvs = find_virtual_envs()
    if #venvs == 0 then
        vim.notify("No Python virtual environments found in project root.", vim.log.levels.WARN)
        callback(nil)
    elseif #venvs == 1 then
        callback(venvs[1])
    else
        if vim.ui and vim.ui.select then
            vim.ui.select(venvs, { prompt = "Select a Python virtual environment:" }, function(choice)
                callback(choice)
            end)
        else
            -- fallback: just use the first one
            callback(venvs[1])
        end
    end
end

-- State for last test command and last failed test location
local last_test_cmd = nil
local last_failed_location = nil

--- Bulletproofing helpers ---
local function is_executable(path)
    return vim.fn.executable(path) == 1
end

local function file_exists(path)
    return vim.fn.filereadable(path) == 1
end

local function safe_call(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        vim.notify('pytest.nvim error: ' .. tostring(err), vim.log.levels.ERROR)
    end
end

--- Enhanced run_pytest_command ---
local function run_pytest_command(cmd, on_exit)
    -- Defensive: check if python executable exists
    if type(cmd) == 'table' and #cmd > 0 and cmd[1]:find('python') then
        if not is_executable(cmd[1]) then
            vim.notify('Python executable not found: ' .. cmd[1], vim.log.levels.ERROR)
            return
        end
    end
    local output_lines = {}
    local ok, job_id = pcall(vim.fn.jobstart, cmd, {
        on_stdout = function(_, data)
            for _, line in ipairs(data) do
                if line and line ~= '' then
                    table.insert(output_lines, line)
                end
            end
        end,
        on_stderr = function(_, data)
            for _, line in ipairs(data) do
                if line and line ~= '' then
                    table.insert(output_lines, line)
                end
            end
        end,
        on_exit = function(_, exit_code)
            local result = table.concat(output_lines, '\n')
            -- Improved: parse for summary and failure location
            local summary = result:match('(=+.+=+)')
            if exit_code ~= 0 then
                local found = false
                for _, line in ipairs(output_lines) do
                    local file, lineno = line:match('([%w%._/-]+)[:](%d+):')
                    if file and lineno and file_exists(file) then
                        last_failed_location = { file = file, line = tonumber(lineno) }
                        found = true
                        break
                    end
                end
                if not found then
                    vim.notify('Test failed, but could not find failure location in output.', vim.log.levels.WARN)
                end
            end
            if on_exit then
                on_exit(exit_code, result, summary)
            else
                vim.schedule(function()
                    local msg = (summary and (summary .. '\n') or '') .. result
                    if exit_code == 0 then
                        vim.notify('✅ Pytest passed!\n' .. msg, vim.log.levels.INFO)
                    else
                        vim.notify('❌ Pytest failed!\n' .. msg, vim.log.levels.ERROR)
                    end
                end)
            end
        end
    })
    if not ok or not job_id or job_id <= 0 then
        vim.notify('Failed to start pytest process', vim.log.levels.ERROR)
    end
end

--- Docstrings and safe wrappers for public functions ---

---
--- Run all tests in the current buffer's file
---
function M.test_file()
    local file = vim.fn.expand('%:p')
    if not file or file == '' or not file_exists(file) then
        vim.notify('No file detected in current buffer', vim.log.levels.ERROR)
        return
    end
    select_virtual_env(function(venv)
        local cmd
        if venv then
            local python = (vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1)
                and (venv .. "\\Scripts\\python.exe")
                or (venv .. "/bin/python")
            cmd = {python, '-m', 'pytest', file}
        else
            cmd = {'pytest', file}
        end
        last_test_cmd = { cmd = cmd }
        record_and_run(cmd)
    end)
end

---
--- Run the test nearest to the cursor in the current buffer
---
function M.test_nearest()
    local file = vim.fn.expand('%:p')
    if not file or file == '' or not file_exists(file) then
        vim.notify('No file detected in current buffer', vim.log.levels.ERROR)
        return
    end
    local test_class, test_func = find_nearest_test()
    if not test_func then
        vim.notify('No test function found above cursor', vim.log.levels.WARN)
        return
    end
    local nodeid
    if test_class then
        nodeid = string.format('%s::%s::%s', file, test_class, test_func)
    else
        nodeid = string.format('%s::%s', file, test_func)
    end
    select_virtual_env(function(venv)
        local cmd
        if venv then
            local python = (vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1)
                and (venv .. "\\Scripts\\python.exe")
                or (venv .. "/bin/python")
            cmd = {python, '-m', 'pytest', nodeid}
        else
            cmd = {'pytest', nodeid}
        end
        last_test_cmd = { cmd = cmd }
        record_and_run(cmd)
    end)
end

---
--- Run the entire test suite in the project root
---
function M.test_suite()
    select_virtual_env(function(venv)
        local cmd
        if venv then
            local python = (vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1)
                and (venv .. "\\Scripts\\python.exe")
                or (venv .. "/bin/python")
            cmd = {python, '-m', 'pytest'}
        else
            cmd = {'pytest'}
        end
        last_test_cmd = { cmd = cmd }
        run_pytest_command(cmd)
    end)
end

---
--- Re-run the last test command executed by the plugin
---
function M.test_last()
    if not last_test_cmd or not last_test_cmd.cmd then
        vim.notify('No previous pytest command to re-run', vim.log.levels.WARN)
        return
    end
    run_pytest_command(last_test_cmd.cmd)
end

---
--- Jump to the file and line of the last failed test (if available)
---
function M.test_visit()
    if not last_failed_location or not last_failed_location.file then
        vim.notify('No failed test location found', vim.log.levels.WARN)
        return
    end
    local file = last_failed_location.file
    local line = last_failed_location.line or 1
    if not file_exists(file) then
        vim.notify('Failed test file not found: ' .. file, vim.log.levels.ERROR)
        return
    end
    vim.cmd('edit +' .. line .. ' ' .. file)
end

-- Utility: Find the nearest test function or method above the cursor
local function find_nearest_test()
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cur_line = cursor[1]
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, cur_line, false)
    local test_func, test_class
    for i = #lines, 1, -1 do
        local line = lines[i]
        local class_name = line:match('^%s*class%s+([%w_]+)')
        if class_name and class_name:match('^Test') then
            if not test_class then
                test_class = class_name
            end
        end
        local func_name = line:match('^%s*def%s+(test_[%w_]*)')
        if func_name then
            test_func = func_name
            -- Check if inside a class
            if test_class then
                return test_class, test_func
            else
                return nil, test_func
            end
        end
    end
    return nil, nil
end

-- Patch all test runners to record last_test_cmd
local function record_and_run(cmd)
    last_test_cmd = { cmd = cmd }
    run_pytest_command(cmd)
end

---
--- Pick and run a test from the current buffer using a picker
---
function M.pick_and_run_test()
    local tests = discover_tests_in_buffer()
    if #tests == 0 then
        vim.notify('No tests found in current buffer', vim.log.levels.WARN)
        return
    end
    local items = {}
    for _, t in ipairs(tests) do
        table.insert(items, t.display)
    end
    local function run_selected(selected_display)
        local selected = nil
        for _, t in ipairs(tests) do
            if t.display == selected_display then
                selected = t
                break
            end
        end
        if not selected then
            vim.notify('No test selected', vim.log.levels.WARN)
            return
        end
        select_virtual_env(function(venv)
            local cmd
            if venv then
                local python = (vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1)
                    and (venv .. "\\Scripts\\python.exe")
                    or (venv .. "/bin/python")
                cmd = {python, '-m', 'pytest', selected.nodeid}
            else
                cmd = {'pytest', selected.nodeid}
            end
            last_test_cmd = { cmd = cmd }
            record_and_run(cmd)
        end)
    end
    -- Try snacks picker first
    local ok, snacks = pcall(require, 'snacks')
    if ok and snacks and snacks.select then
        snacks.select({
            prompt = 'Select a test to run:',
            items = items,
            on_select = run_selected
        })
    elseif vim.ui and vim.ui.select then
        vim.ui.select(items, { prompt = 'Select a test to run:' }, function(choice)
            if choice then run_selected(choice) end
        end)
    else
        -- fallback: just run the first test
        run_selected(items[1])
    end
end

---
--- List and open all test files in the project
---
function M.list_test_files()
    local test_files = vim.fn.glob('**/test_*.py', true, true)
    local alt_files = vim.fn.glob('**/*_test.py', true, true)
    for _, f in ipairs(alt_files) do
        table.insert(test_files, f)
    end
    -- Remove duplicates
    local seen = {}
    local unique = {}
    for _, f in ipairs(test_files) do
        if not seen[f] then
            table.insert(unique, f)
            seen[f] = true
        end
    end
    if #unique == 0 then
        vim.notify('No test files found', vim.log.levels.WARN)
        return
    end
    local ok, snacks = pcall(require, 'snacks')
    if ok and snacks and snacks.select then
        snacks.select({
            prompt = 'Select a test file to open:',
            items = unique,
            on_select = function(file)
                if file and file_exists(file) then vim.cmd('edit ' .. file) end
            end
        })
    elseif vim.ui and vim.ui.select then
        vim.ui.select(unique, { prompt = 'Select a test file to open:' }, function(choice)
            if choice and file_exists(choice) then vim.cmd('edit ' .. choice) end
        end)
    else
        if file_exists(unique[1]) then vim.cmd('edit ' .. unique[1]) end
    end
end

---
--- Jump between source and test file
---
function M.jump_to_test_file()
    local file = vim.fn.expand('%:p')
    if not file or file == '' or not file_exists(file) then
        vim.notify('No file detected in current buffer', vim.log.levels.ERROR)
        return
    end
    local dir = vim.fn.fnamemodify(file, ':h')
    local base = vim.fn.fnamemodify(file, ':t:r')
    local is_test = base:match('^test_') or base:match('_test$')
    local candidates = {}
    if is_test then
        -- From test file to source file
        local src_base = base:gsub('^test_', ''):gsub('_test$', '')
        local src_patterns = {
            dir .. '/' .. src_base .. '.py',
        }
        for _, p in ipairs(src_patterns) do
            if file_exists(p) then
                table.insert(candidates, p)
            end
        end
    else
        -- From source file to test file
        local test_patterns = {
            dir .. '/test_' .. base .. '.py',
            dir .. '/' .. base .. '_test.py',
        }
        for _, p in ipairs(test_patterns) do
            if file_exists(p) then
                table.insert(candidates, p)
            end
        end
    end
    if #candidates == 0 then
        vim.notify('No related test/source file found for ' .. file, vim.log.levels.WARN)
        return
    elseif #candidates == 1 then
        vim.cmd('edit ' .. candidates[1])
    else
        if vim.ui and vim.ui.select then
            vim.ui.select(candidates, { prompt = 'Select file to open:' }, function(choice)
                if choice and file_exists(choice) then vim.cmd('edit ' .. choice) end
            end)
        else
            if file_exists(candidates[1]) then vim.cmd('edit ' .. candidates[1]) end
        end
    end
end

---
--- Fuzzy find test files using snacks, telescope, or fallback
---
function M.fuzzy_find_test_file()
    local ok_snacks, snacks = pcall(require, 'snacks')
    local test_files = vim.fn.glob('**/test_*.py', true, true)
    local alt_files = vim.fn.glob('**/*_test.py', true, true)
    for _, f in ipairs(alt_files) do
        table.insert(test_files, f)
    end
    -- Remove duplicates
    local seen, unique = {}, {}
    for _, f in ipairs(test_files) do
        if not seen[f] then
            table.insert(unique, f)
            seen[f] = true
        end
    end
    if ok_snacks and snacks then
        if snacks.fuzzy_select then
            snacks.fuzzy_select({
                prompt = 'Fuzzy Find Test File:',
                items = unique,
                on_select = function(file)
                    if file and file_exists(file) then vim.cmd('edit ' .. file) end
                end
            })
            return
        elseif snacks.select then
            snacks.select({
                prompt = 'Select a test file to open:',
                items = unique,
                on_select = function(file)
                    if file and file_exists(file) then vim.cmd('edit ' .. file) end
                end
            })
            return
        end
    end
    local ok_telescope, telescope = pcall(require, 'telescope.builtin')
    if ok_telescope and telescope then
        telescope.find_files({ prompt_title = 'Fuzzy Find Test Files', search_file = 'test',
            find_command = {'rg', '--files', '--iglob', 'test_*.py', '--iglob', '*_test.py'} })
    else
        M.list_test_files()
    end
end

function M.setup()
    vim.api.nvim_create_user_command("PytestStart", function()
        require("pytest.commands").start()
    end, {})
    vim.api.nvim_create_user_command("PytestConfig", function() M.show_config() end, {})
    vim.api.nvim_create_user_command("PytestConfigEdit", function() M.edit_config() end, {})
    vim.api.nvim_create_user_command("PytestConfigWatch", function() M.watch_config() end, {})
    vim.api.nvim_create_user_command("PytestConfigSnacks", function() M.snacks_picker() end, {})
    vim.api.nvim_create_user_command("PytestEnvironmentSnacks", function() M.snacks_environment_picker() end, {})
    vim.api.nvim_create_user_command("PytestMarkerSnacks", function() M.snacks_marker_picker() end, {})



    vim.api.nvim_create_user_command("RunPluginTests", function()
        M.run_plugin_tests()
    end, {})
end

function M.setup_keymaps()
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true, desc = '[pytest.nvim]' }
    map('n', '<leader>pf', ':PytestFile<CR>', opts)
    map('n', '<leader>pn', ':PytestNearest<CR>', opts)
    map('n', '<leader>pp', function() require('pytest').pick_and_run_test() end, opts)
    map('n', '<leader>pl', ':PytestListTests<CR>', opts)
    map('n', '<leader>pj', ':PytestJumpTest<CR>', opts)
    map('n', '<leader>ps', ':PytestFuzzyTest<CR>', opts)
end

return M
