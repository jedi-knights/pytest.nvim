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

  -- 1️⃣ Picker for environment variables
  pickers.new({}, {
    prompt_title = "Select Environment",
    finder = finders.new_table {
      results = envs,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        local selected_env = selection and selection[1]

        -- 2️⃣ After selecting env, do markers picker
        M.select_markers_and_run(selected_env)
      end)
      return true
    end,
  }):find()
end

function M.select_markers_and_run(selected_env)
  local available_markers = markers.get_markers()
  if #available_markers == 0 then
    vim.notify("No markers found in pytest.ini", vim.log.levels.WARN)
    return runner.run_all({ env = selected_env })  -- fallback
  end

  -- Multi-select markers picker
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

        -- If no multi-select, fallback to single
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
        runner.run_all({ env = selected_env, markers = marker_str })
      end)
      return true
    end,
  }):find()
end

return M
