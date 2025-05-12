local M = require("pytest")

describe("pytest.init integration", function()

    it("finds and parses pytest.ini in test project", function(done)
        -- Arrange
        local cwd = vim.fn.getcwd()
        vim.cmd("cd tests/projects/project1")

        -- Act
        M.read_pytest_config(function(cfg)
            -- Assert
            assert.is_truthy(cfg["addopts"])
            assert.are.same("-ra", cfg["addopts"])
            vim.cmd("cd " .. cwd)
            done()
        end)
    end)

end)
