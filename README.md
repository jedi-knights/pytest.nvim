# pytest.nvim

**pytest.nvim** is a Neovim plugin that provides tight integration with the Pytest framework for Python.

With `pytest.nvim`, you can execute tests directly from within Neovim, review results in the quickfix window, and (in upcoming versions) interactively select markers, environments, and other Pytest options. This plugin is designed to enhance the feedback loop for Python developers working with tests inside Neovim.

---

## ✨ Features

- Execute Pytest:
  - On the current file
  - On the nearest test (coming soon)
  - Across the entire project
- Display test results in the quickfix window
- Support for customizable Pytest arguments
- Lightweight and minimal dependencies, using Neovim's native APIs

**Planned enhancements:**

- Interactive Telescope picker for markers and environments
- Inline virtual text to annotate test failures and errors
- Floating windows for summary reports
- JSON output parsing for detailed diagnostics and reporting

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

**With native `vim.pack` (Neovim ≥ 0.12):**

`vim.pack.add` does not run `setup()` for you — the follow-up call is explicit.
`snacks.nvim` powers the interactive pickers and should be added alongside.

```lua
vim.pack.add({
  { src = "https://github.com/folke/snacks.nvim" },
  { src = "https://github.com/jedi-knights/pytest.nvim" },
})

require("pytest").setup()
```

Pin to a tag or branch with `version = "..."`. `vim.pack.add` is idempotent —
it clones on first run and does nothing on subsequent runs. Use
`:lua vim.pack.update()` to pull new commits.

**With Packer:**

```lua
use {
  "jedi-knights/pytest.nvim",
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

## 🔑 Default Keymaps

The plugin sets up the following keymaps by default (called via `setup_keymaps()`):

| Keymap | Command | Description |
|--------|---------|-------------|
| `<leader>pts` | `:PytestStart` | Start pytest |
| `<leader>ptc` | `:PytestConfig` | Show pytest config |
| `<leader>pte` | `:PytestConfigEdit` | Edit pytest config |
| `<leader>ptw` | `:PytestConfigWatch` | Watch pytest config |
| `<leader>ptf` | `:RunTests` | Run tests in current file |
| `<leader>ptn` | `:PytestNearest` | Run nearest test |

### Custom Keymaps

You can also define your own keymaps:

```lua
vim.keymap.set('n', '<leader>tf', ":lua require('pytest').run_file()<CR>", { desc = "Pytest: Run file" })
vim.keymap.set('n', '<leader>tn', ":lua require('pytest').run_nearest()<CR>", { desc = "Pytest: Run nearest" })
vim.keymap.set('n', '<leader>ta', ":lua require('pytest').run_all()<CR>", { desc = "Pytest: Run all" })
```

---

## 🛠 Usage

| Command                                  | Description                           |
|------------------------------------------|---------------------------------------|
| `:lua require('pytest').run_file()`      | Run tests in the current file         |
| `:lua require('pytest').run_all()`       | Run all tests in the project          |
| `:lua require('pytest').run_nearest()`   | Run the nearest test (coming soon)    |

Test results are populated into the **quickfix** window, allowing easy navigation and inspection.

---

## ✅ Testing the Plugin

We use [**Busted**](https://olivinelabs.com/busted/) for Lua unit testing.

### 1️⃣ Install Busted (via LuaRocks)

```bash
luarocks install busted
```

💡 It's recommended to install Busted **locally** (project-specific) using:

```bash
luarocks init
luarocks install busted
```

### 2️⃣ Run Tests

I will be using plenary to test things in this plugin.


### 3️⃣ Example Test


---

## 🗺 Roadmap

- [ ] Telescope picker for environments and markers
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

