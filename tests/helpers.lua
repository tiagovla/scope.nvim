local M = {}
local temp_dir

local function fail(message, lhs, rhs)
    local caller = debug.getinfo(3, "Sl")
    error(
        string.format(
            "FAIL: %s\n  lhs: %s\n  rhs: %s\n  at %s:%d",
            message or "assertion failed",
            vim.inspect(lhs),
            vim.inspect(rhs),
            caller.short_src,
            caller.currentline
        ),
        0
    )
end

function M.assert(condition, message)
    if not condition then
        fail(message, condition, true)
    end
    return condition
end

function M.assert_true(value, message)
    if not value then
        fail(message or "expected true", value, true)
    end
    return value
end

function M.assert_false(value, message)
    if value then
        fail(message or "expected false", value, false)
    end
    return not value
end

function M.assert_equal(lhs, rhs, message)
    if not vim.deep_equal(lhs, rhs) then
        fail(message or "values are not equal", lhs, rhs)
    end
    return lhs
end

function M.temp_file(name, lines)
    local path = temp_dir .. "/" .. name
    M.assert(vim.fn.writefile(lines or { "" }, path) == 0, "could not create temp file: " .. path)
    return path
end

function M.reset_nvim_session()
    vim.cmd("silent! tabonly!")
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
    end
    local core = require("scope.core")
    core.cache = {}
    core.last_tab = 0
    vim.g.ScopeState = nil
    vim.cmd("enew!")
end

function M.run(test)
    local ok, err = xpcall(function()
        vim.opt.swapfile = false
        temp_dir = vim.fn.tempname()
        M.assert(vim.fn.mkdir(temp_dir, "p") == 1, "could not create temp directory")
        require("scope").setup()
        test(M)
    end, debug.traceback)
    vim.fn.delete(temp_dir, "rf")
    if not ok then
        error(err, 0)
    end
end

return M
