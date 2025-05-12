local parser = require("pytest.parser")

describe("pytest.parser", function()

    it("parses pytest.ini correctly", function()
        -- Arrange
        local ini = [[
[pytest]
addopts = -ra
python_files = test_*.py
        ]]

        -- Act
        local config = parser.parse_ini(ini)

        -- Assert
        assert.are.same("-ra", config["addopts"])
        assert.are.same("test_*.py", config["python_files"])
    end)

    it("parses pyproject.toml correctly", function()
        -- Arrange
        local toml = [[
[tool.pytest.ini_options]
addopts = "-ra"
python_files = "test_*.py"
        ]]

        -- Act
        local config = parser.parse_toml(toml)

        -- Assert
        assert.are.same('"-ra"', config["addopts"])
        assert.are.same('"test_*.py"', config["python_files"])
    end)

end)
