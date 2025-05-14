vim.opt.runtimepath:append(".")
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/plenary.nvim")

-- Optional: Set minimal config options
vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")

