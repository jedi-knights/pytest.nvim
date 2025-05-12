local Path = require("plenary.path")
local detect = require("pytest.detect")

describe("pytest.detect", function()
  local test_dir = Path:new("tests/tmp_detect")

  before_each(function()
    test_dir:mkdir({ parents = true })
    vim.fn.chdir(test_dir:absolute())
  end)

  after_each(function()
    test_dir:rm({ recursive = true })
  end)

  it("returns true if pytest.ini exists", function()
    Path:new("pytest.ini"):write("[pytest]", "w")
    assert.is_true(detect.should_load_plugin())
  end)

  it("returns true if pyproject.toml has [tool.pytest]", function()
    Path:new("pyproject.toml"):write("[tool.pytest]\naddopts = \"-ra\"", "w")
    assert.is_true(detect.should_load_plugin())
  end)

  it("returns true if pyproject.toml has [tool.pytest.ini_options]", function()
    Path:new("pyproject.toml"):write("[tool.pytest.ini_options]\nlog_cli = true", "w")
    assert.is_true(detect.should_load_plugin())
  end)

  it("returns false if no files exist", function()
    assert.is_false(detect.should_load_plugin())
  end)

  it("returns false if pyproject.toml has unrelated config", function()
    Path:new("pyproject.toml"):write("[tool.black]\nline-length = 88", "w")
    assert.is_false(detect.should_load_plugin())
  end)
end)

