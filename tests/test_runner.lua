local runner = require("pytest.runner")

describe("runner", function()
  it("should build a pytest command for a file", function()
    local file = "tests/test_sample.py"
    local cmd = runner.build_command(file)
    assert.is_table(cmd)
    assert.are.equal(cmd[1], "pytest")
    assert.are.equal(cmd[2], file)
  end)
end)

