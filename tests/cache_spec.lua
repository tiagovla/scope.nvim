local test_utils = require("tests.test_utils")

describe("tab buffer cache", function()
    before_each(test_utils.setup)
    after_each(test_utils.teardown)

    it("lists a buffer opened from another tab with :buffer (#14)", function()
        vim.cmd.edit(test_utils.temp_file("shared.lua"))
        local shared_buf = vim.api.nvim_get_current_buf()
        vim.cmd.edit(test_utils.temp_file("private.lua"))
        local private_buf = vim.api.nvim_get_current_buf()

        vim.cmd.tabnew()
        local tab = vim.api.nvim_get_current_tabpage()
        assert.equals(0, vim.fn.buflisted(shared_buf))

        vim.cmd("buffer " .. shared_buf)

        assert.equals(tab, vim.api.nvim_get_current_tabpage())
        assert.equals(shared_buf, vim.api.nvim_get_current_buf())
        assert.equals(1, vim.fn.buflisted(shared_buf), "the buffer opened in this tab should appear in :ls")
        assert.equals(0, vim.fn.buflisted(private_buf), "the other buffer should stay scoped to its original tab")

        vim.cmd.tabprevious()
        assert.is_true(vim.tbl_contains(require("scope.core").cache[tab], shared_buf))
        vim.cmd.tabnext()
        assert.equals(
            1,
            vim.fn.buflisted(shared_buf),
            "the opened buffer should stay listed when returning to this tab"
        )
        assert.equals(0, vim.fn.buflisted(private_buf))
    end)

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
