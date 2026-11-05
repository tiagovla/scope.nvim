local test = dofile("tests/helpers.lua")

test.run(function(t)
    local core = require("scope.core")
    local retained_file = t.temp_file("retained.lua")
    local deleted_file = t.temp_file("deleted.lua")

    vim.cmd.edit(retained_file)
    local retained_buf = vim.api.nvim_get_current_buf()
    vim.cmd.edit(deleted_file)
    local deleted_buf = vim.api.nvim_get_current_buf()
    local tab = vim.api.nvim_get_current_tabpage()

    core.close_buffer({ buf = deleted_buf, force = true })

    t.assert_false(vim.api.nvim_buf_is_valid(deleted_buf), "close_buffer should delete the unshared buffer")
    t.assert_equal(vim.api.nvim_get_current_buf(), retained_buf, "close_buffer should select the remaining buffer")
    local cached = t.assert(core.cache[tab], "missing tab cache after close_buffer")
    t.assert_equal(#cached, 1, "cache should keep only the remaining buffer")
    t.assert_equal(cached[1], retained_buf, "cache should keep the retained buffer")
end)
