vim.opt.runtimepath:append(".")
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site/pack/packer/start/plenary.nvim")

local Path = require("plenary.path")
local detect = require("pytest.detect")

describe("init", function()
    local test_dir = Path:new("tests/tmp_detect")

    before_each(function()
        test_dir:mkdir({ parents = true })
        vim.fn.chdir(test_dir:absolute())
    end)

    after_each(function()
        test_dir:rm({ recursive = true })
    end)

    it("should load plugin if pytest.ini exists", function()
    end)

    it("should load plugin if pyproject.toml has [tool.pytest]", function()
    end)

    it("should load plugin if pyproject.toml has [tool.pytest.ini_options]", function()
    end)

    it("should not load plugin if no files exist", function()
    end)

    it("should not load plugin if pyproject.toml has unrelated config", function()
    end)
end)


