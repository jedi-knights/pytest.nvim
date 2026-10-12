-- Characterization tests for the command surface in lua/pytest/init.lua.
-- We stub out `vim.cmd` so the specs never actually spawn a terminal; the
-- assertions check that each public function records the right command in
-- the module's `last_pytest_cmd` / `last_test_file` state so :PytestLast
-- and :PytestVisit have something to act on.

describe("pytest commands", function()
	local pytest
	local original_cmd
	local recorded_cmd
	local original_notify
	local recorded_notifications

	before_each(function()
		package.loaded["pytest"] = nil
		pytest = require("pytest")
		pytest._reset_state()
		recorded_cmd = nil
		recorded_notifications = {}
		original_cmd = vim.cmd
		original_notify = vim.notify
		---@diagnostic disable-next-line: duplicate-set-field
		vim.cmd = function(c)
			recorded_cmd = c
		end
		---@diagnostic disable-next-line: duplicate-set-field
		vim.notify = function(msg, lvl)
			table.insert(recorded_notifications, { msg = msg, lvl = lvl })
		end
	end)

	after_each(function()
		vim.cmd = original_cmd
		vim.notify = original_notify
	end)

	describe("test_file", function()
		it("notifies and bails when the current buffer has no file name", function()
			-- Fresh scratch buffer has `%` → "" per nvim semantics.
			local buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_set_current_buf(buf)

			pytest.test_file()

			assert.equals(1, #recorded_notifications)
			assert.truthy(recorded_notifications[1].msg:find("No file in current buffer", 1, true))
			assert.is_nil(pytest._last_pytest_cmd())
		end)

		it("records the pytest command and the test file when the buffer has a name", function()
			local buf = vim.api.nvim_create_buf(true, false)
			vim.api.nvim_buf_set_name(buf, "/tmp/pytest_spec_target.py")
			vim.api.nvim_set_current_buf(buf)

			pytest.test_file()

			local last = pytest._last_pytest_cmd()
			assert.truthy(last)
			assert.truthy(last:find("pytest ", 1, true))
			assert.truthy(last:find("pytest_spec_target.py", 1, true))
			assert.truthy(pytest._last_test_file():find("pytest_spec_target.py", 1, true))

			vim.api.nvim_buf_delete(buf, { force = true })
		end)

		it("appends extra arguments after the file", function()
			local buf = vim.api.nvim_create_buf(true, false)
			vim.api.nvim_buf_set_name(buf, "/tmp/pytest_spec_target.py")
			vim.api.nvim_set_current_buf(buf)

			pytest.test_file("-v", "-x")

			local last = pytest._last_pytest_cmd()
			assert.truthy(last:find("-v", 1, true))
			assert.truthy(last:find("-x", 1, true))

			vim.api.nvim_buf_delete(buf, { force = true })
		end)
	end)

	describe("test_suite", function()
		it("fires pytest with no file argument and clears last_test_file", function()
			pytest.test_suite()
			assert.equals("vsplit | terminal pytest", recorded_cmd)
			assert.is_nil(pytest._last_test_file())
		end)

		it("appends extra arguments verbatim", function()
			pytest.test_suite("-k", "smoke", "--maxfail=1")
			local last = pytest._last_pytest_cmd()
			assert.truthy(last:find("-k smoke", 1, true))
			assert.truthy(last:find("--maxfail=1", 1, true))
		end)
	end)

	describe("test_last", function()
		it("notifies when there is no previous invocation", function()
			pytest.test_last()
			assert.equals(1, #recorded_notifications)
			assert.truthy(recorded_notifications[1].msg:find("No previous pytest invocation", 1, true))
		end)

		it("replays the most recent pytest command", function()
			pytest.test_suite("-k", "fast")
			local expected = pytest._last_pytest_cmd()
			recorded_cmd = nil

			pytest.test_last()
			assert.equals("vsplit | terminal " .. expected, recorded_cmd)
		end)
	end)

	describe("visit", function()
		it("notifies when no test file has been exercised yet", function()
			pytest.visit()
			assert.equals(1, #recorded_notifications)
			assert.truthy(recorded_notifications[1].msg:find("No test file to visit", 1, true))
		end)

		it("notifies when the last test file is no longer readable", function()
			local buf = vim.api.nvim_create_buf(true, false)
			vim.api.nvim_buf_set_name(buf, "/tmp/pytest_visit_missing.py")
			vim.api.nvim_set_current_buf(buf)
			pytest.test_file() -- stores last_test_file but the file doesn't exist
			vim.api.nvim_buf_delete(buf, { force = true })

			pytest.visit()
			local last = recorded_notifications[#recorded_notifications]
			assert.truthy(last.msg:find("no longer readable", 1, true))
		end)
	end)
end)
