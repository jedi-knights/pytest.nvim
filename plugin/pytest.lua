vim.api.nvim_create_user_command("PytestFile", function(args)
  require("pytest").test_file(unpack(args.fargs))
end, { nargs = "*" })

vim.api.nvim_create_user_command("PytestNearest", function(args)
  require("pytest").test_nearest(unpack(args.fargs))
end, { nargs = "*" })

vim.api.nvim_create_user_command("PytestSuite", function(args)
  require("pytest").test_suite(unpack(args.fargs))
end, { nargs = "*" })

vim.api.nvim_create_user_command("PytestLast", function(args)
  require("pytest").test_last(unpack(args.fargs))
end, { nargs = "*" })

vim.api.nvim_create_user_command("PytestVisit", function()
  require("pytest").visit()
end, {})

vim.api.nvim_create_user_command("PytestListTests", function()
  require("pytest").list_test_files()
end, {})

vim.api.nvim_create_user_command("PytestJumpTest", function()
  require("pytest").jump_to_test_file()
end, {})

vim.api.nvim_create_user_command("PytestFuzzyTest", function()
  require("pytest").fuzzy_find_test_file()
end, {})

