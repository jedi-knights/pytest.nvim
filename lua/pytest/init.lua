local M = {}
local Job = require("plenary.job")
local parser = require("pytest.parser")
local utils = require("pytest.utils")

local files_to_check = {
    { name = "pytest.ini", parser = parser.parse_ini },
    { name = "pyproject.toml", parser = parser.parse_toml },
}

local config = {}

function M.read_pytest_config(callback)
    Job:new({
        command = "find",
        args = { ".", "-maxdepth", "3", "-name", "*.ini", "-o", "-name", "*.toml" },
        on_exit = function(j)
            local files = j:result()
            for _, file in ipairs(files) do
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
            vim.schedule(function()
                vim.notify("pytest config not found", vim.log.levels.WARN)
            end)
        end,
    }):start()
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

function M.telescope_picker()
    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values

    M.read_pytest_config(function(cfg)
        local entries = {}
        for k, v in pairs(cfg) do
            table.insert(entries, k .. " = " .. v)
        end

        pickers.new({}, {
            prompt_title = 'Pytest Config',
            finder = finders.new_table(entries),
            sorter = conf.generic_sorter({}),
        }):find()
    end)
end


function M.run_plugin_tests()
    Job:new({
        command = "nvim",
        args = {
            "--headless",
            "-c",
            "PlenaryBustedDirectory tests/ tests/minimal_init.lua"
        },
        on_exit = function(j, return_val)
            local result = table.concat(j:result(), "\n")
            vim.schedule(function()
                if return_val == 0 then
                    vim.notify("✅ Plugin tests passed!\n" .. result, vim.log.levels.INFO)
                else
                    vim.notify("❌ Plugin tests failed!\n" .. result, vim.log.levels.ERROR)
                end
            end)
        end,
    }):start()
end

function M.test_nearest()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cur_line = cursor[1]
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, cur_line, false)

  local test_name, class_name
  -- Search upwards for the nearest test function or class
  for i = #lines, 1, -1 do
    local line = lines[i]
    local func = line:match("^%s*def%s+(test[%w_]*)")
    if func and not test_name then
      test_name = func
    end
    local class = line:match("^%s*class%s+(Test[%w_]*)")
    if class and not class_name then
      class_name = class
    end
    if test_name and class_name then break end
  end

  local file = vim.fn.expand("%")
  local nodeid
  if test_name and class_name then
    nodeid = string.format("%s::%s::%s", file, class_name, test_name)
  elseif test_name then
    nodeid = string.format("%s::%s", file, test_name)
  elseif class_name then
    nodeid = string.format("%s::%s", file, class_name)
  else
    vim.notify("No test function or class found above cursor.", vim.log.levels.WARN)
    return
  end

  -- Run pytest on the nodeid in a terminal split
  vim.cmd("vsplit | terminal pytest " .. vim.fn.shellescape(nodeid))
end

function M.setup()
    vim.api.nvim_create_user_command("PytestStart", function()
        require("pytest.commands").start()
    end, {})
    vim.api.nvim_create_user_command("PytestConfig", function() M.show_config() end, {})
    vim.api.nvim_create_user_command("PytestConfigEdit", function() M.edit_config() end, {})
    vim.api.nvim_create_user_command("PytestConfigWatch", function() M.watch_config() end, {})
    vim.api.nvim_create_user_command("PytestConfigTelescope", function() M.telescope_picker() end, {})

    vim.api.nvim_create_user_command("RunTests", function()
        local file = vim.fn.expand("%")
        vim.cmd("vsplit | terminal nvim --headless -c 'PlenaryBustedFile " .. file .. " tests/minimal_init.lua'")
    end, {})

    vim.api.nvim_create_user_command("RunPluginTests", function()
        M.run_plugin_tests()
    end, {})
end

function M.setup_keymaps()
    print("setup_keymaps loaded from:" .. debug.getinfo(1).source)
  -- Keymaps for all user-facing commands, prefixed with <leader>p
  vim.keymap.set("n", "<leader>ps", ":PytestStart<CR>", { desc = "Pytest: Start" })
  vim.keymap.set("n", "<leader>pc", ":PytestConfig<CR>", { desc = "Pytest: Show Config" })
  vim.keymap.set("n", "<leader>pe", ":PytestConfigEdit<CR>", { desc = "Pytest: Edit Config" })
  vim.keymap.set("n", "<leader>pw", ":PytestConfigWatch<CR>", { desc = "Pytest: Watch Config" })
  vim.keymap.set("n", "<leader>pf", ":RunTests<CR>", { desc = "Pytest: Run Tests in File" })
  vim.keymap.set("n", "<leader>pn", ":PytestNearest<CR>", { desc = "Pytest: Run Nearest Test" })
end

return M
