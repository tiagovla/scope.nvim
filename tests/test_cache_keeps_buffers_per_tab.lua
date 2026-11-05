local test = dofile("tests/helpers.lua")

test.run(function(t)
    local core = require("scope.core")

    local function assert_cached(tab, expected)
        local actual = vim.deepcopy(t.assert(core.cache[tab], "missing tab cache"))
        local wanted = vim.deepcopy(expected)
        table.sort(actual)
        table.sort(wanted)
        t.assert_equal(actual, wanted, "cache contents do not match")
    end

    local files = {
        t.temp_file("tab1-a.lua"),
        t.temp_file("tab1-b.lua"),
        t.temp_file("tab2-a.lua"),
        t.temp_file("tab2-b.lua"),
    }

    vim.cmd.edit(files[1])
    local tab1_buf_a = vim.api.nvim_get_current_buf()
    vim.cmd.edit(files[2])
    local tab1_buf_b = vim.api.nvim_get_current_buf()
    local tab1 = vim.api.nvim_get_current_tabpage()

    vim.cmd.tabnew(files[3])
    local tab2_buf_a = vim.api.nvim_get_current_buf()
    local tab2 = vim.api.nvim_get_current_tabpage()
    vim.cmd.edit(files[4])
    local tab2_buf_b = vim.api.nvim_get_current_buf()
    vim.api.nvim_set_current_tabpage(tab1)

    assert_cached(tab1, { tab1_buf_a, tab1_buf_b })
    assert_cached(tab2, { tab2_buf_a, tab2_buf_b })
end)
