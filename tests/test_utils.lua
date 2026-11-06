local M = {}
local temp_dir

function M.assert_names(names, expected, label)
    local actual = vim.deepcopy(names)
    local wanted = vim.deepcopy(expected)
    table.sort(actual)
    table.sort(wanted)
    assert.same(wanted, actual, "cached files do not match in " .. label)
end

function M.assert_cache(tab, expected, label)
    local core = require("scope.core")
    assert.is_not_nil(core.cache[tab], "missing cache for " .. label)
    local buffers = core.cache[tab]
    local names = {}
    for _, buf in ipairs(buffers) do
        assert.is_true(vim.api.nvim_buf_is_valid(buf), "invalid cached buffer in " .. label)
        names[#names + 1] = vim.api.nvim_buf_get_name(buf)
    end
    M.assert_names(names, expected, label)
end

function M.temp_file(name, lines)
    local path = temp_dir .. "/" .. name
    assert.equals(0, vim.fn.writefile(lines or { "" }, path), "could not create temp file: " .. path)
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

function M.setup()
    temp_dir = vim.fn.tempname()
    assert.equals(1, vim.fn.mkdir(temp_dir, "p"), "could not create temp directory")
    M.reset_nvim_session()
    require("scope").setup()
end

function M.teardown()
    M.reset_nvim_session()
    vim.fn.delete(temp_dir, "rf")
end

return M
