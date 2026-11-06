local test_utils = require("tests.test_utils")

describe("close_buffer", function()
    before_each(test_utils.setup)
    after_each(test_utils.teardown)

    it("deletes an unshared buffer and retains the remaining buffer", function()
        local core = require("scope.core")
        local retained_file = test_utils.temp_file("retained.lua")
        local deleted_file = test_utils.temp_file("deleted.lua")

        vim.cmd.edit(retained_file)
        local retained_buf = vim.api.nvim_get_current_buf()
        vim.cmd.edit(deleted_file)
        local deleted_buf = vim.api.nvim_get_current_buf()
        local tab = vim.api.nvim_get_current_tabpage()

        core.close_buffer({ buf = deleted_buf, force = true })

        assert.is_false(vim.api.nvim_buf_is_valid(deleted_buf), "close_buffer should delete the unshared buffer")
        assert.equals(retained_buf, vim.api.nvim_get_current_buf(), "close_buffer should select the remaining buffer")
        assert.is_not_nil(core.cache[tab], "missing tab cache after close_buffer")
        local cached = core.cache[tab]
        assert.equals(1, #cached, "cache should keep only the remaining buffer")
        assert.equals(retained_buf, cached[1], "cache should keep the retained buffer")
    end)
end)
