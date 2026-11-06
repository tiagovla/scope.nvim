local test_utils = require("tests.test_utils")

describe("tab buffer cache", function()
    before_each(test_utils.setup)
    after_each(test_utils.teardown)

    it("keeps each tab's buffers separate", function()
        local core = require("scope.core")

        local function assert_cached(tab, expected)
            assert.is_not_nil(core.cache[tab], "missing tab cache")
            local actual = vim.deepcopy(core.cache[tab])
            local wanted = vim.deepcopy(expected)
            table.sort(actual)
            table.sort(wanted)
            assert.same(wanted, actual, "cache contents do not match")
        end

        local files = {
            test_utils.temp_file("tab1-a.lua"),
            test_utils.temp_file("tab1-b.lua"),
            test_utils.temp_file("tab2-a.lua"),
            test_utils.temp_file("tab2-b.lua"),
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
end)
