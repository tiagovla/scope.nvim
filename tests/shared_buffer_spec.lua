local test_utils = require("tests.test_utils")

describe("shared tab buffers", function()
    before_each(test_utils.setup)
    after_each(test_utils.teardown)

    it("keeps the remaining buffer active after deleting a buffer shared by split tabs (#4)", function()
        vim.cmd.edit(test_utils.temp_file("retained.lua"))
        local retained_buf = vim.api.nvim_get_current_buf()
        vim.cmd.edit(test_utils.temp_file("shared.lua"))
        local shared_buf = vim.api.nvim_get_current_buf()

        vim.cmd.split()
        vim.cmd("wincmd T")

        local tabs = vim.api.nvim_list_tabpages()
        assert.equals(2, #tabs)
        for _, tab in ipairs(tabs) do
            local win = vim.api.nvim_tabpage_get_win(tab)
            assert.equals(shared_buf, vim.api.nvim_win_get_buf(win))
        end

        vim.cmd.bdelete()

        assert.is_true(
            vim.wait(1000, function()
                return vim.api.nvim_get_current_buf() == retained_buf
            end),
            "the remaining buffer should become active after :bdelete"
        )
        assert.equals(retained_buf, vim.api.nvim_get_current_buf(), ":bdelete should select the remaining buffer")
        assert.equals(1, vim.fn.buflisted(retained_buf), "the remaining buffer should stay listed after :bdelete")
    end)

    it("preserves an unrelated tab's cache when deletion closes an inactive tab", function()
        local core = require("scope.core")
        vim.cmd.edit(test_utils.temp_file("retained.lua"))
        local retained_buf = vim.api.nvim_get_current_buf()
        vim.cmd.edit(test_utils.temp_file("shared.lua"))
        local original_tab = vim.api.nvim_get_current_tabpage()
        vim.cmd.split()
        vim.cmd("wincmd T")
        local shared_tab = vim.api.nvim_get_current_tabpage()

        local unrelated_file = test_utils.temp_file("unrelated.lua")
        vim.cmd.tabnew(unrelated_file)
        local unrelated_tab = vim.api.nvim_get_current_tabpage()
        local unrelated_buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_set_current_tabpage(shared_tab)

        vim.cmd.bdelete()

        assert.is_true(vim.wait(1000, function()
            return vim.api.nvim_get_current_buf() == retained_buf
        end))
        assert.equals(retained_buf, vim.api.nvim_get_current_buf())
        assert.is_nil(core.cache[original_tab], "the closed tab's cache should be removed")
        test_utils.assert_cache(unrelated_tab, { unrelated_file }, "unrelated tab")
        assert.equals(0, vim.fn.buflisted(unrelated_buf), "the unrelated buffer should stay scoped to its tab")

        vim.api.nvim_set_current_tabpage(unrelated_tab)
        assert.equals(1, vim.fn.buflisted(unrelated_buf))
        assert.equals(0, vim.fn.buflisted(retained_buf))
    end)

    it("does not import the closed tab's other buffers after :tabclose", function()
        vim.cmd.edit(test_utils.temp_file("original-only.lua"))
        local original_buf = vim.api.nvim_get_current_buf()
        vim.cmd.edit(test_utils.temp_file("shared.lua"))
        local shared_buf = vim.api.nvim_get_current_buf()
        local original_tab = vim.api.nvim_get_current_tabpage()
        vim.cmd.split()
        vim.cmd("wincmd T")
        vim.api.nvim_set_current_tabpage(original_tab)

        vim.cmd.tabclose()

        assert.equals(shared_buf, vim.api.nvim_get_current_buf())
        assert.equals(1, vim.fn.buflisted(shared_buf))
        assert.equals(0, vim.fn.buflisted(original_buf), "the closed tab's private buffer should stay unlisted")
    end)
end)
