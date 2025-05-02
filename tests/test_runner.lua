local runner = require("pytest.runner")

describe("runner", function()
  it("should build a pytest command with a file", function()
    local file = "tests/test_example.py"
    local cmd = runner.build_command(file)
    assert.is_table(cmd)
    assert.is_truthy(vim.tbl_contains(cmd, file))
    assert.are.equal(cmd[1], "python3")
    assert.are.equal(cmd[3], "pytest")
  end)

  it("should build a pytest command without a file", function()
    local cmd = runner.build_command(nil)
    assert.is_table(cmd)
    assert.is_not_nil(cmd)
    assert.is_nil(cmd[#cmd], "Expected no file at end")
  end)
end)

