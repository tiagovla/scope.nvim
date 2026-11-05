local test = dofile("tests/helpers.lua")

test.run(function(t)
    local core = require("scope.core")

    local function assert_names(names, expected, label)
        local actual = vim.deepcopy(names)
        local wanted = vim.deepcopy(expected)
        table.sort(actual)
        table.sort(wanted)
        t.assert_equal(actual, wanted, "cached files do not match in " .. label)
    end

    local function assert_cache(tab, expected, label)
        local buffers = t.assert(core.cache[tab], "missing cache for " .. label)
        local names = {}
        for _, buf in ipairs(buffers) do
            t.assert(vim.api.nvim_buf_is_valid(buf), "invalid cached buffer in " .. label)
            names[#names + 1] = vim.api.nvim_buf_get_name(buf)
        end
        assert_names(names, expected, label)
    end

    local files = {
        t.temp_file("tab1-a.lua"),
        t.temp_file("tab1-b.lua"),
        t.temp_file("tab2-a.lua"),
        t.temp_file("tab2-b.lua"),
    }
    local session_file = t.temp_file("scope.session")

    -- Save two distinct tab scopes to a session file.
    vim.opt.sessionoptions = { "buffers", "tabpages", "globals" }
    vim.cmd.edit(files[1])
    vim.cmd.edit(files[2])
    local tab1 = vim.api.nvim_get_current_tabpage()
    vim.cmd.tabnew(files[3])
    vim.cmd.edit(files[4])
    vim.api.nvim_set_current_tabpage(tab1)

    vim.cmd.ScopeSaveState()
    local saved = vim.json.decode(vim.g.ScopeState)
    assert_names(saved.cache[1], { files[1], files[2] }, "saved tab 1")
    assert_names(saved.cache[2], { files[3], files[4] }, "saved tab 2")
    t.assert_equal(saved.last_tab, 1, "save should record current tab")
    vim.cmd.mksession({ args = { session_file }, bang = true })

    -- Wipe current tabs and buffers, then source the saved session in this Neovim.
    t.reset_nvim_session()
    t.assert_equal(#vim.api.nvim_list_tabpages(), 1, "reset should leave one tab")
    vim.cmd("source " .. vim.fn.fnameescape(session_file))
    vim.cmd.ScopeLoadState()

    local tabs = vim.api.nvim_list_tabpages()
    t.assert_equal(#tabs, 2, "restore should recover two tabs")
    assert_cache(tabs[1], { files[1], files[2] }, "restored tab 1")
    assert_cache(tabs[2], { files[3], files[4] }, "restored tab 2")
    t.assert_equal(core.last_tab, tabs[1], "restore should recover saved last tab")

    local current = vim.api.nvim_get_current_tabpage()
    for _, tab in ipairs(tabs) do
        for _, buf in ipairs(core.cache[tab]) do
            t.assert_equal(
                vim.api.nvim_buf_get_option(buf, "buflisted"),
                tab == current,
                "restore should list only current tab buffers"
            )
        end
    end
end)
