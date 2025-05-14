-- tests/test_detect_spec.lua
local Path = require("plenary.path")
local detect = require("pytest.detect")

describe("pytest_ini_exists", function()
  local temp_dir
  local original_dir

  before_each(function()
    original_dir = vim.fn.getcwd()

    local tmp = vim.loop.fs_mkdtemp("/tmp/pytest-nvim-test-XXXXXX")
    temp_dir = Path:new(tmp)
    vim.fn.chdir(temp_dir:absolute())
  end)

  after_each(function()
    temp_dir:rm({ recursive = true })
    vim.fn.chdir(original_dir)
  end)

  it("returns true if pytest.ini exists", function()
    local pytest_ini = temp_dir:joinpath("pytest.ini")
    pytest_ini:write("[pytest]", "w")

    local result = detect.pytest_ini_exists()
    assert.is_true(result)
  end)

  it("returns false if pytest.ini does not exist", function()
    local result = detect.pytest_ini_exists()
    assert.is_false(result)
  end)
end)

describe("pyproject_toml_exists", function()
  local temp_dir
  local original_dir

  before_each(function()
    original_dir = vim.fn.getcwd()

    local tmp = vim.loop.fs_mkdtemp("/tmp/pytest-nvim-test-XXXXXX")
    temp_dir = Path:new(tmp)
    vim.fn.chdir(temp_dir:absolute())
  end)

  after_each(function()
    temp_dir:rm({ recursive = true })
    vim.fn.chdir(original_dir)
  end)

  it("returns true if pyproject.toml exists", function()
    local pyproject_toml = temp_dir:joinpath("pyproject.toml")
    pyproject_toml:write("[tool.pytest]", "w")

    local result = detect.pyproject_toml_exists()
    assert.is_true(result)
  end)

  it("returns false if pyproject.toml does not exist", function()
    local result = detect.pyproject_toml_exists()
    assert.is_false(result)
  end)
end)

describe("pyproject_toml_lists_pytest", function()
  local temp_dir
  local original_dir

  before_each(function()
    original_dir = vim.fn.getcwd()

    local tmp = vim.loop.fs_mkdtemp("/tmp/pytest-nvim-test-XXXXXX")
    temp_dir = Path:new(tmp)
    vim.fn.chdir(temp_dir:absolute())
  end)

  after_each(function()
    temp_dir:rm({ recursive = true })
    vim.fn.chdir(original_dir)
  end)

  it("returns true if pyproject.toml lists pytest", function()
    local pyproject_toml = temp_dir:joinpath("pyproject.toml")
    pyproject_toml:write("[tool.pytest]\npytest = '6.2.4'", "w")

    local result = detect.pyproject_toml_lists_pytest()
    assert.is_true(result)
  end)

  it("returns false if pyproject.toml does not list pytest", function()
    local pyproject_toml = temp_dir:joinpath("pyproject.toml")
    pyproject_toml:write("[tool.something]\nanother_dependency = '1.0.0'", "w")

    local result = detect.pyproject_toml_lists_pytest()
    assert.is_false(result)
  end)
end)

describe("requirements_txt_lists_pytest", function()
  local temp_dir
  local original_dir

  before_each(function()
    original_dir = vim.fn.getcwd()

    local tmp = vim.loop.fs_mkdtemp("/tmp/pytest-nvim-test-XXXXXX")
    temp_dir = Path:new(tmp)
    vim.fn.chdir(temp_dir:absolute())
  end)

  after_each(function()
    temp_dir:rm({ recursive = true })
    vim.fn.chdir(original_dir)
  end)

  it("returns true if requirements.txt lists pytest", function()
    local requirements_txt = temp_dir:joinpath("requirements.txt")
    requirements_txt:write("pytest==6.2.4\nother_package==1.0.0", "w")

    local result = detect.requirements_txt_lists_pytest()
    assert.is_true(result)
  end)

  it("returns false if requirements.txt does not list pytest", function()
    local requirements_txt = temp_dir:joinpath("requirements.txt")
    requirements_txt:write("other_package==1.0.0\nanother_package==2.0.0", "w")

    local result = detect.requirements_txt_lists_pytest()
    assert.is_false(result)
  end)
end)

describe("setup_cfg_lists_pytest", function()
  local temp_dir
  local original_dir

  before_each(function()
    original_dir = vim.fn.getcwd()

    local tmp = vim.loop.fs_mkdtemp("/tmp/pytest-nvim-test-XXXXXX")
    temp_dir = Path:new(tmp)
    vim.fn.chdir(temp_dir:absolute())
  end)

  after_each(function()
    temp_dir:rm({ recursive = true })
    vim.fn.chdir(original_dir)
  end)

  it("returns true if setup.cfg lists pytest", function()
    local setup_cfg = temp_dir:joinpath("setup.cfg")
    setup_cfg:write("[options]\ninstall_requires = pytest==6.2.4\nother_package==1.0.0", "w")

    local result = detect.setup_cfg_lists_pytest()
    assert.is_true(result)
  end)

  it("returns false if setup.cfg does not list pytest", function()
    local setup_cfg = temp_dir:joinpath("setup.cfg")
    setup_cfg:write("[options]\ninstall_requires = other_package==1.0.0\nanother_package==2.0.0", "w")

    local result = detect.setup_cfg_lists_pytest()
    assert.is_false(result)
  end)
end)

describe("has_test_files", function() 
  local temp_dir
  local original_dir

  before_each(function()
    original_dir = vim.fn.getcwd()

    local tmp = vim.loop.fs_mkdtemp("/tmp/pytest-nvim-test-XXXXXX")
    temp_dir = Path:new(tmp)
    vim.fn.chdir(temp_dir:absolute())
  end)

  after_each(function()
    temp_dir:rm({ recursive = true })
    vim.fn.chdir(original_dir)
  end)

  it("returns true if test files are found", function()
    local test_file = temp_dir:joinpath("test_example.py")
    test_file:write("def test_example():\n    assert True", "w")

    local result = detect.has_test_files()
    assert.is_true(result)
  end)

  it("returns false if no test files are found", function()
    local result = detect.has_test_files()
    assert.is_false(result)
  end)
end)

describe("pytest_toml_contains_pytest", function() 
  local temp_dir
  local original_dir

  before_each(function()
    original_dir = vim.fn.getcwd()

    local tmp = vim.loop.fs_mkdtemp("/tmp/pytest-nvim-test-XXXXXX")
    temp_dir = Path:new(tmp)
    vim.fn.chdir(temp_dir:absolute())
  end)

  after_each(function()
    temp_dir:rm({ recursive = true })
    vim.fn.chdir(original_dir)
  end)

  it("returns true if pyproject.toml contains pytest", function()
    local pyproject_toml = temp_dir:joinpath("pyproject.toml")
    pyproject_toml:write("[tool.pytest]\npytest = '6.2.4'", "w")

    local result = detect.pyproject_toml_contains_pytest()
    assert.is_true(result)
  end)

  it("returns false if pyproject.toml does not contain pytest", function()
    local pyproject_toml = temp_dir:joinpath("pyproject.toml")
    pyproject_toml:write("[tool.something]\nanother_dependency = '1.0.0'", "w")

    local result = detect.pyproject_toml_contains_pytest()
    assert.is_false(result)
  end)
end)

describe("should_load_plugin", function() 
  local temp_dir
  local original_dir

  before_each(function()
    original_dir = vim.fn.getcwd()

    local tmp = vim.loop.fs_mkdtemp("/tmp/pytest-nvim-test-XXXXXX")
    temp_dir = Path:new(tmp)
    vim.fn.chdir(temp_dir:absolute())
  end)

  after_each(function()
    temp_dir:rm({ recursive = true })
    vim.fn.chdir(original_dir)
  end)

  it("returns true if pytest is detected", function()
    local pytest_ini = temp_dir:joinpath("pytest.ini")
    pytest_ini:write("[pytest]", "w")

    local result = detect.should_load_plugin()
    assert.is_true(result)
  end)

  it("returns false if pytest is not detected", function()
    local result = detect.should_load_plugin()
    assert.is_false(result)
  end)
end)


