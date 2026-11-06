local test_utils = require("tests.test_utils")

describe("new tab buffers", function()
    before_each(test_utils.setup)
    after_each(test_utils.teardown)

    it("keeps the copied buffer listed after :tab sb", function()
        vim.cmd.edit(test_utils.temp_file("copied.lua"))
        local buf = vim.api.nvim_get_current_buf()

        vim.cmd("tab sb")

        assert.equals(2, #vim.api.nvim_list_tabpages())
        assert.equals(buf, vim.api.nvim_get_current_buf())
        assert.equals(1, vim.fn.buflisted(buf), "the buffer copied to the new tab should appear in :ls")

        vim.cmd.tabprevious()
        assert.equals(1, vim.fn.buflisted(buf), "the buffer should remain listed in the original tab")
        vim.cmd.tabnext()
        assert.equals(1, vim.fn.buflisted(buf), "the buffer should remain listed when returning to the new tab")
    end)

    it("keeps a hidden buffer in the original tab after :tab sb", function()
        vim.cmd.edit(test_utils.temp_file("copied.lua"))
        local copied_buf = vim.api.nvim_get_current_buf()
        vim.cmd.edit(test_utils.temp_file("original.lua"))
        local original_buf = vim.api.nvim_get_current_buf()

        vim.cmd("tab sb " .. copied_buf)

        assert.equals(copied_buf, vim.api.nvim_get_current_buf())

        vim.cmd.tabprevious()

        assert.equals(original_buf, vim.api.nvim_get_current_buf())
        assert.equals(1, vim.fn.buflisted(original_buf))
        assert.equals(1, vim.fn.buflisted(copied_buf), "a copied buffer should remain scoped to the original tab")
    end)

    it("keeps the moved buffer listed after <C-W>T", function()
        vim.cmd.edit(test_utils.temp_file("moved.lua"))
        local buf = vim.api.nvim_get_current_buf()
        vim.cmd.split()

        vim.cmd("wincmd T")

        assert.equals(2, #vim.api.nvim_list_tabpages())
        assert.equals(buf, vim.api.nvim_get_current_buf())
        assert.equals(1, vim.fn.buflisted(buf), "the buffer moved to the new tab should appear in :ls")

        vim.cmd.tabprevious()
        assert.equals(1, vim.fn.buflisted(buf), "the buffer should remain listed in the original tab")
        vim.cmd.tabnext()
        assert.equals(1, vim.fn.buflisted(buf), "the buffer should remain listed when returning to the new tab")
    end)

    it("removes a moved buffer from the original tab after <C-W>T (#25)", function()
        vim.cmd.edit(test_utils.temp_file("retained.lua"))
        local retained_buf = vim.api.nvim_get_current_buf()
        vim.cmd.vsplit()
        vim.cmd.edit(test_utils.temp_file("moved.lua"))
        local moved_buf = vim.api.nvim_get_current_buf()

        vim.cmd("wincmd T")

        assert.equals(2, #vim.api.nvim_list_tabpages())
        assert.equals(moved_buf, vim.api.nvim_get_current_buf())
        assert.equals(1, vim.fn.buflisted(moved_buf), "the moved buffer should be listed in the new tab")
        assert.equals(0, vim.fn.buflisted(retained_buf), "the retained buffer should stay scoped to the original tab")

        vim.cmd.tabprevious()

        assert.equals(retained_buf, vim.api.nvim_get_current_buf())
        assert.equals(1, vim.fn.buflisted(retained_buf))
        assert.equals(0, vim.fn.buflisted(moved_buf), "the moved buffer should no longer be listed in the original tab")

        vim.cmd.tabnext()

        assert.equals(moved_buf, vim.api.nvim_get_current_buf())
        assert.equals(1, vim.fn.buflisted(moved_buf))
        assert.equals(0, vim.fn.buflisted(retained_buf))
    end)

    it("does not list the previous tab's buffer after :tabnew", function()
        vim.cmd.edit(test_utils.temp_file("original.lua"))
        local original_buf = vim.api.nvim_get_current_buf()

        vim.cmd.tabnew()
        local new_buf = vim.api.nvim_get_current_buf()

        assert.equals(2, #vim.api.nvim_list_tabpages())
        assert.is_not.equals(original_buf, new_buf)
        assert.equals(1, vim.fn.buflisted(new_buf), "the new tab's buffer should appear in :ls")
        assert.equals(0, vim.fn.buflisted(original_buf), "the previous tab's buffer should not appear in :ls")

        vim.cmd.tabprevious()
        assert.equals(1, vim.fn.buflisted(original_buf), "the original tab should recover its listed buffer")
        assert.equals(0, vim.fn.buflisted(new_buf), "the new tab's buffer should stay scoped to that tab")
        vim.cmd.tabnext()
        assert.equals(0, vim.fn.buflisted(original_buf), "the previous tab's buffer should stay scoped to that tab")
        assert.equals(1, vim.fn.buflisted(new_buf), "the new tab should recover its listed buffer")
    end)
end)
