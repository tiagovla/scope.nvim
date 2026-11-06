local test_utils = require("tests.test_utils")

describe("session state", function()
    test_utils.setup()
    local files = {
        test_utils.temp_file("tab1-a.lua"),
        test_utils.temp_file("tab1-b.lua"),
        test_utils.temp_file("tab2-a.lua"),
        test_utils.temp_file("tab2-b.lua"),
    }
    local session_file = test_utils.temp_file("scope.session")

    before_each(test_utils.reset_nvim_session)

    it("saves tab scopes to a session file", function()
        vim.cmd.edit(files[1])
        vim.cmd.edit(files[2])
        local tab1 = vim.api.nvim_get_current_tabpage()
        vim.cmd.tabnew(files[3])
        vim.cmd.edit(files[4])
        vim.api.nvim_set_current_tabpage(tab1)

        vim.cmd.ScopeSaveState()
        local saved = vim.json.decode(vim.g.ScopeState)
        test_utils.assert_names(saved.cache[1], { files[1], files[2] }, "saved tab 1")
        test_utils.assert_names(saved.cache[2], { files[3], files[4] }, "saved tab 2")
        assert.equals(1, saved.last_tab, "save should record current tab")
        vim.opt.sessionoptions = { "buffers", "tabpages", "globals" }
        vim.cmd.mksession({ args = { session_file }, bang = true })
    end)

    it("loads tab scopes from a session file", function()
        local core = require("scope.core")

        assert.equals(1, #vim.api.nvim_list_tabpages(), "reset should leave one tab")
        vim.cmd("source " .. vim.fn.fnameescape(session_file))
        vim.cmd.ScopeLoadState()

        local tabs = vim.api.nvim_list_tabpages()
        assert.equals(2, #tabs, "restore should recover two tabs")
        test_utils.assert_cache(tabs[1], { files[1], files[2] }, "restored tab 1")
        test_utils.assert_cache(tabs[2], { files[3], files[4] }, "restored tab 2")
        assert.equals(tabs[1], core.last_tab, "restore should recover saved last tab")

        local current = vim.api.nvim_get_current_tabpage()
        for _, tab in ipairs(tabs) do
            for _, buf in ipairs(core.cache[tab]) do
                assert.equals(
                    tab == current,
                    vim.api.nvim_buf_get_option(buf, "buflisted"),
                    "restore should list only current tab buffers"
                )
            end
        end
    end)

    test_utils.teardown()
end)
