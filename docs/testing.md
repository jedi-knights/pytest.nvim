# Testing a Local Neovim Plugin Before Committing

When developing your Neovim plugin (e.g., `pytest.nvim`), it's very useful to test it **locally** before pushing to GitHub. Here are multiple ways to do that effectively.

---

## 1️⃣ Add It as a Local Path in Lazy.nvim

If you're using **Lazy.nvim**, you can directly point to your **local directory** in the plugin spec.

### Example:

```lua
{
  "jedi-knights/pytest.nvim",
  dir = "~/src/pytest.nvim",
  -- any other options like config = ...
}
```

✅ **Benefits:**

* Loads the plugin **from your local path**.
* Supports **hot reloading** with `:Lazy reload pytest.nvim`.

---

## 2️⃣ Symlink the Plugin into Lazy's Directory

Find where Lazy installs plugins, typically:

```
~/.local/share/nvim/lazy/
```

Then create a symlink:

```bash
ln -s ~/src/pytest.nvim ~/.local/share/nvim/lazy/pytest.nvim
```

✅ **This lets Lazy think it’s installed, but actually uses your local code.**

---

## 3️⃣ Manual Runtimepath Injection

For quick tests, open Neovim and run:

```vim
:set rtp+=~/src/pytest.nvim
```

Then load your plugin:

```lua
:lua require('pytest')
```

✅ **Good for quick experiments.**

---

## 4️⃣ Use `nvim --clean` with a Minimal Config

Create a minimal Neovim config file:

```lua
-- ~/pytest-test/init.lua
vim.opt.rtp:append("~/src/pytest.nvim")
require("pytest").setup()
```

Then launch Neovim with:

```bash
nvim --clean -u ~/pytest-test/init.lua
```

✅ **Great for isolated testing with no interference from your full setup.**

---

# Bonus Tips

* Lazy.nvim **detects changes automatically** when using `dir =`. But you can always force a reload:

```vim
:Lazy reload pytest.nvim
```

* To fully reload the plugin after edits:

```vim
:source %
:lua require("lazy").reload("pytest.nvim")
```

---

# ✅ Recommendation

The **cleanest approach** is to use Lazy.nvim with:

```lua
{
  "jedi-knights/pytest.nvim",
  dir = "~/src/pytest.nvim",
}
```

It works just like a GitHub plugin but uses your **local folder**, allowing fast iteration and reloads.

