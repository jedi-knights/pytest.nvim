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

