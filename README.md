# pytest.nvim

**pytest.nvim** is a Neovim plugin that provides tight integration with the Pytest framework for Python.

## Overview

If you already use pytest, you know the loop: run tests in a terminal, read the failure, switch back to the editor, navigate to the file and line, fix, repeat. `pytest.nvim` collapses that cycle: run the nearest test (or the whole file) from the current buffer, review results in the quickfix window, and jump straight to failures without leaving Neovim.

---

## Features

- Run the nearest pytest test from the current buffer (`:PytestNearest`)
- Interactive Telescope picker for the active pytest configuration (`:PytestConfigTelescope`)
- Read, show, edit, and watch the project's `pytest.ini` / `pyproject.toml` config
- User commands wired up out of the box (no keymap setup required to call them)

**Planned enhancements:**

- Running the whole file / whole suite as first-class exported functions
- JSON output parsing for detailed diagnostics and reporting
- Inline virtual text for inline error/failure display
- Floating window summaries of test results
- Coverage reporting integration

---

## Requirements

- Neovim 0.9+ (0.12+ recommended for native `vim.pack` support)
- [`nvim-lua/plenary.nvim`](https://github.com/nvim-lua/plenary.nvim) — required (used for async jobs)
- [`nvim-telescope/telescope.nvim`](https://github.com/nvim-telescope/telescope.nvim) — optional, required only for `:PytestConfigTelescope`
- `pytest` available on `$PATH` (install via `pip install pytest` or your project's package manager)

---

## Installation

**With Lazy.nvim:**

```lua
{
  "jedi-knights/pytest.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("pytest").setup()
  end,
}
```

**With native `vim.pack` (Neovim ≥ 0.12):**

`vim.pack.add` does not run `setup()` for you — the follow-up call is explicit.

```lua
vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/jedi-knights/pytest.nvim" },
})

require("pytest").setup()
```

Pin to a tag or branch with `version = "..."`. `vim.pack.add` is idempotent — it clones on first run and does nothing on subsequent runs. Use `:lua vim.pack.update()` to pull new commits.

**With Packer:**

```lua
use {
  "jedi-knights/pytest.nvim",
  requires = { "nvim-lua/plenary.nvim" },
  config = function()
    require("pytest").setup()
  end,
}
```

---

## Configuration

`require("pytest").setup()` currently takes no options — call it with no arguments to register the user commands below. Configuration surface for `python_command`, `pytest_args`, and environment/region selectors is planned; the public shape is not yet finalized and is intentionally not documented here to avoid drift.

---

## Default Keymaps

The plugin does **not** set any keymaps by default. A `setup_keymaps()` helper is provided and binds the following under `<leader>pt*` when called explicitly:

| Keymap | Command | Description |
|--------|---------|-------------|
| `<leader>pts` | `:PytestStart` | Start pytest (loads project config) |
| `<leader>ptc` | `:PytestConfig` | Show pytest config |
| `<leader>pte` | `:PytestConfigEdit` | Edit pytest config |
| `<leader>ptw` | `:PytestConfigWatch` | Watch pytest config |
| `<leader>ptf` | `:RunTests` | Run Busted (plenary) against the current buffer — intended for this plugin's own Lua tests, not pytest |
| `<leader>ptn` | `:PytestNearest` | Run nearest test |

Opt in by calling `require("pytest").setup_keymaps()` after `setup()`.

### Custom Keymaps

Define your own keymaps against the exported functions and user commands:

```lua
vim.keymap.set("n", "<leader>tn", ":lua require('pytest').test_nearest()<CR>", { desc = "Pytest: Run nearest" })
vim.keymap.set("n", "<leader>tc", ":lua require('pytest').show_config()<CR>", { desc = "Pytest: Show config" })
vim.keymap.set("n", "<leader>tp", ":lua require('pytest').telescope_picker()<CR>", { desc = "Pytest: Telescope config picker" })
```

---

## Usage

### User commands

| Command | Description |
|---|---|
| `:PytestStart` | Load `.pytest.cfg.json` and announce environments/regions |
| `:PytestNearest` | Run the nearest pytest test from the current buffer in a terminal split |
| `:PytestConfig` | Show the detected pytest config (`pytest.ini` or `pyproject.toml`) |
| `:PytestConfigEdit` | Open the detected pytest config for editing |
| `:PytestConfigWatch` | Watch the detected pytest config for changes |
| `:PytestConfigTelescope` | Telescope picker over the detected pytest config entries |
| `:RunPluginTests` | Run this plugin's own Lua test suite (Busted via plenary) |

### Lua API

| Call | Description |
|---|---|
| `require("pytest").test_nearest()` | Run the nearest pytest test from the current buffer |
| `require("pytest").show_config()` | Show the detected pytest config |
| `require("pytest").edit_config()` | Open the detected pytest config for editing |
| `require("pytest").watch_config()` | Watch the detected pytest config for changes |
| `require("pytest").telescope_picker()` | Telescope picker over the detected pytest config |
| `require("pytest").run_plugin_tests()` | Run this plugin's own Lua test suite |

`:PytestNearest` executes `pytest <file>::<Class>::<test>` in a terminal split. Quickfix integration for failure navigation is on the roadmap.

---

## Development

Clone the repo and run the plugin's own test suite with [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)'s Busted runner:

```bash
git clone https://github.com/nvim-lua/plenary.nvim \
  ~/.local/share/nvim/site/pack/packer/start/plenary.nvim

nvim --headless -c "PlenaryBustedDirectory tests/ tests/minimal_init.lua"
```

The same command runs in CI (see `.github/workflows/`). Inside a running Neovim, `:RunPluginTests` wraps the same invocation.

---

## Roadmap

- [ ] Exported `test_file` / `test_suite` / `test_last` / `visit` functions matching the user commands in `plugin/pytest.lua`
- [ ] Quickfix integration for failure navigation
- [ ] JSON output parsing and error diagnostics
- [ ] Inline virtual text for inline error/failure display
- [ ] Floating window summaries of test results
- [ ] Coverage reporting integration

---

## Contributing

Your contributions are welcome! Feel free to open issues for bugs, feature requests, or submit pull requests to help improve the plugin.

---

## License

Distributed under the [MIT License](LICENSE).

## References

- [Structuring Neovim Lua Plugins](https://zignar.net/2022/11/06/structuring-neovim-lua-plugins/)
- [Create Neovim Plugins with Lua](http://youtube.com/watch?v=wkxtHV1hzEY)
- [Neovim Lua Plugin from Scratch](https://www.youtube.com/watch?v=n4Lp4cV8YR0)
- [An example minimal plugin](https://github.com/lewis6991/spaceless.nvim)
- [Plugin Boilerplate](https://github.com/shortcuts/neovim-plugin-boilerplate)
- [vim.tbl_deep_extend](https://neovim.io/doc/user/lua.html#vim.tbl_deep_extend%28%29)
