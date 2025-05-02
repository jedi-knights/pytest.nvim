package = "pytest.nvim"
version = "dev-1"
source = {
   url = "git+https://github.com/jedi-knights/pytest.nvim"
}
description = {
   detailed = "**pytest.nvim** is a Neovim plugin that provides tight integration with the Pytest framework for Python.",
   homepage = "https://github.com/jedi-knights/pytest.nvim",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {
      ["pytest.config"] = "lua/pytest/config.lua",
      ["pytest.init"] = "lua/pytest/init.lua",
      ["pytest.parser"] = "lua/pytest/parser.lua",
      ["pytest.runner"] = "lua/pytest/runner.lua",
      ["pytest.ui"] = "lua/pytest/ui.lua"
   },
   copy_directories = {
      "docs"
   }
}
