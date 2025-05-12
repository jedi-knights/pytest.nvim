local Path = require("plenary.path")
local fs = require("pytest.fs")

describe("pytest.fs", function()
  local test_dir = Path:new("tests/tmp_fs")

  before_each(function()
    test_dir:mkdir({ parents = true })
    vim.fn.chdir(test_dir:absolute())
  end)

  after_each(function()
    test_dir:rm({ recursive = true })
  end)

  it("detects existing file", function()
    Path:new("sample.txt"):write("hello world", "w")
    assert.is_true(fs.file_exists("sample.txt"))
  end)

  it("returns false for missing file", function()
    assert.is_false(fs.file_exists("nonexistent.txt"))
  end)

  it("detects existing directory", function()
    Path:new("mydir"):mkdir()
    assert.is_true(fs.dir_exists("mydir"))
  end)

  it("returns false for missing directory", function()
    assert.is_false(fs.dir_exists("ghostdir"))
  end)

  it("reads file content", function()
    Path:new("note.md"):write("neovim is awesome", "w")
    local content = fs.read_file("note.md")
    assert.are.same("neovim is awesome", content)
  end)

  it("returns nil for unreadable or missing file", function()
    assert.is_nil(fs.read_file("nowhere.txt"))
  end)
end)

