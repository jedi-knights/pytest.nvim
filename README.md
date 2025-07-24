# pytest.nvim

**pytest.nvim** is a Neovim plugin that provides tight integration with the Pytest framework for Python.

With `pytest.nvim`, you can execute tests directly from within Neovim, review results in the quickfix window, and interactively select markers, environments, and other Pytest options. This plugin is designed to enhance the feedback loop for Python developers working with tests inside Neovim.

---

## ✨ Features

- Execute Pytest:
  - On the current file
  - On the nearest test (coming soon)
  - Across the entire project
- Display test results in the quickfix window
- Support for customizable Pytest arguments
- Lightweight and minimal dependencies, using Neovim's native APIs and job management
- Interactive pickers using Snacks for environment and marker selection
- Configuration viewing and editing

**Planned enhancements:**

- Inline virtual text to annotate test failures and errors
- Floating windows for summary reports
- JSON output parsing for detailed diagnostics and reporting
- Advanced test result filtering and navigation

---

## 🚀 Installation

**With Lazy.nvim:**

```lua
{
  "jedi-knights/pytest.nvim",
  config = function()
    require("pytest").setup()
  end,
}
```

**With Packer:**

```lua
use {
  "jedi-knights/pytest.nvim",
  requires = {
    "folke/snacks.nvim",
  },
  config = function()
    require("pytest").setup()
  end,
}
```

---
## 📦 Dependencies

This plugin requires the following dependencies:

- **Snacks** (`folke/snacks.nvim`) - For interactive pickers (environment, marker, and config selection)

**With Lazy.nvim:**

```lua
{
  "jedi-knights/pytest.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    require("pytest").setup()
  end,
}
```

---
## ⚙️ Setup

To customize settings, add the following to your Neovim config:

```lua
require('pytest').setup({
  python_command = "python3",
  pytest_args = {"-v", "--tb=short"},
  -- Define available environment variables (the first value will be the default)
  envs = {
    ENVIRONMENT = { "qa", "prod" },
    REGION = { "auto", "use1", "usw2", "euw1", "apse1" }
  },
})
```

In this example:
- ✅ You’ll be able to select **ENVIRONMENT** values like `prod`, `qa`, or `auto`.
- ✅ You can also select **REGION** values like `us-east-1`, `us-west-2`, or `eu-west-1`.

All configuration fields are optional. The plugin will apply default values if no setup options are provided.

---

## 🔑 Example Keymaps

For fast access to testing commands, you can add these mappings:

```lua
vim.api.nvim_set_keymap('n', '<leader>tt', ":lua require('pytest').run_nearest()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>tf', ":lua require('pytest').run_file()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ta', ":lua require('pytest').run_all()<CR>", { noremap = true, silent = true })
```

---

## 🛠 Usage

| Command                                  | Description                           |
|------------------------------------------|---------------------------------------|
| `:lua require('pytest').run_file()`      | Run tests in the current file         |
| `:lua require('pytest').run_all()`       | Run all tests in the project          |
| `:lua require('pytest').run_nearest()`   | Run the nearest test (coming soon)    |
| `:PytestConfigSnacks`                    | Interactive config picker using Snacks |
| `:PytestEnvironmentSnacks`               | Select environment using Snacks       |
| `:PytestMarkerSnacks`                    | Select test markers using Snacks      |

Test results are populated into the **quickfix** window, allowing easy navigation and inspection.

### 🍿 Snacks Integration

The plugin provides interactive pickers using Snacks for enhanced user experience:

- **Configuration Picker** (`:PytestConfigSnacks`) - Browse and select pytest configuration options
- **Environment Picker** (`:PytestEnvironmentSnacks`) - Select different test environments
- **Marker Picker** (`:PytestMarkerSnacks`) - Choose specific test markers to run

These pickers provide a modern, interactive way to configure and run your tests with different options.

---

## 💤 Lazy-Loading pytest.nvim (Recommended)

To keep Neovim fast and efficient, you can lazy-load pytest.nvim so it only activates when you open a Python test file.

### Using a Plugin Manager (e.g., lazy.nvim, packer.nvim)

**Example with [lazy.nvim](https://github.com/folke/lazy.nvim):**

```lua
{
  'yourname/pytest.nvim',
  ft = { 'python' }, -- loads for all Python files
  -- Or, to load only for test files:
  event = { 'BufReadPre test_*.py', 'BufReadPre *_test.py' },
  config = function()
    require('pytest').setup_keymaps() -- Optional: set up default keymaps
  end
}
```

### Using a Plain Neovim Autocommand

Add this to your `init.lua` or Neovim config:

```lua
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "test_*.py", "*_test.py" },
  callback = function()
    require('pytest').setup_keymaps() -- Optional: set up default keymaps
    -- You can also require('pytest') here to ensure the plugin is loaded
  end,
  desc = "Load pytest.nvim keymaps for test files"
})
```

- This will only load pytest.nvim keymaps (and any other setup) when you open a Python test file.
- You can safely call `setup_keymaps()` multiple times; it will not duplicate mappings.

### Why Lazy-Load?
- Faster startup time for Neovim
- Only loads pytest.nvim when you need it
- Avoids polluting your keymaps for non-test files

---

## 🔑 Default Keymaps

If you use `require('pytest').setup_keymaps()`, the following mappings are set (all in normal mode):

| Mapping         | Action                        |
|-----------------|------------------------------|
| `<leader>pf`    | Run all tests in file        |
| `<leader>pn`    | Run nearest test             |
| `<leader>pp`    | Pick and run test in file    |
| `<leader>pl`    | List and open test files     |
| `<leader>pj`    | Jump between src/test file   |
| `<leader>ps`    | Fuzzy search for test files  |

You can override or disable these mappings in your own config if needed.

---

## 🗺 Roadmap

- [x] Snacks picker for environments and markers
- [ ] JSON output parsing and error diagnostics
- [ ] Inline virtual text for inline error/failure display
- [ ] Floating window summaries of test results
- [ ] Coverage reporting integration

---

## 💬 Contributing

Your contributions are welcome! Feel free to open issues for bugs, feature requests, or submit pull requests to help improve the plugin.

---

## 📜 License

Distributed under the [MIT License](LICENSE).

## References

- [Structuring Neovim Lua Plugins](https://zignar.net/2022/11/06/structuring-neovim-lua-plugins/)
- [Create Neovim Plugins with Lua](http://youtube.com/watch?v=wkxtHV1hzEY)
- [Neovim Lua Plugin from Scratch](https://www.youtube.com/watch?v=n4Lp4cV8YR0)
- [An example minimal plugin](https://github.com/lewis6991/spaceless.nvim)
- [Plugin Boilerplate](https://github.com/shortcuts/neovim-plugin-boilerplate)
- [vim.tbl_deep_extend](https://neovim.io/doc/user/lua.html#vim.tbl_deep_extend%28%29)

