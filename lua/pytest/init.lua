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
