local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local markers = require("pytest.markers")
local runner = require("pytest.runner")
local config = require("pytest.config")

local M = {}

function M.run_with_ui()
  local envs = config.options.envs or {}
  local selected_env_vars = {}

  -- Helper to select REGION after ENVIRONMENT
  local function select_env_var(var_name, choices, on_done)
    pickers.new({}, {
      prompt_title = "Select " .. var_name,
      finder = finders.new_table {
        results = choices,
      },
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            selected_env_vars[var_name] = selection[1]
            on_done()
          end
        end)
        return true
      end,
    }):find()
  end

  -- Start with selecting ENVIRONMENT
  if envs.ENVIRONMENT then
    select_env_var("ENVIRONMENT", envs.ENVIRONMENT, function()
      -- Next: select REGION
      if envs.REGION then
        select_env_var("REGION", envs.REGION, function()
          -- Finally: select markers
          M.select_markers_and_run(selected_env_vars)
        end)
      else
        -- No REGION defined, jump to markers
        M.select_markers_and_run(selected_env_vars)
      end
    end)
  else
    -- No ENVIRONMENT, skip to markers
    M.select_markers_and_run(selected_env_vars)
  end
end

function M.select_markers_and_run(selected_env_vars)
  local available_markers = markers.get_markers()
  if #available_markers == 0 then
    vim.notify("No markers found in pytest.ini", vim.log.levels.WARN)
    return runner.run_all({ env_vars = selected_env_vars })
  end

  pickers.new({}, {
    prompt_title = "Select Markers (TAB to multi-select)",
    finder = finders.new_table {
      results = available_markers,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local picker = action_state.get_current_picker(prompt_bufnr)
        local multi = picker:get_multi_selection()
        local marker_list = {}

        if vim.tbl_isempty(multi) then
          local selection = action_state.get_selected_entry()
          if selection then
            table.insert(marker_list, selection[1])
          end
        else
          for _, entry in ipairs(multi) do
            table.insert(marker_list, entry[1])
          end
        end

        actions.close(prompt_bufnr)
        local marker_str = table.concat(marker_list, " and ")
        runner.run_all({ env_vars = selected_env_vars, markers = marker_str })
      end)
      return true
    end,
  }):find()
end

return M
