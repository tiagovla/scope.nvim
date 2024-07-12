local utils = require("scope.utils")
local config = require("scope.config")

local M = {}

M.cache = {}
M.last_tab = 0

function M.on_tab_new_entered()
    vim.api.nvim_buf_set_option(0, "buflisted", true)
end

function M.on_tab_enter()
    if config.hooks.pre_tab_enter ~= nil then
        config.hooks.pre_tab_enter()
    end
    local tab = vim.api.nvim_get_current_tabpage()
    local buf_nums = M.cache[tab]
    if buf_nums then
        for _, k in pairs(buf_nums) do
            vim.api.nvim_buf_set_option(k, "buflisted", true)
        end
    end
    if config.hooks.post_tab_enter ~= nil then
        config.hooks.post_tab_enter()
    end
end

function M.on_tab_leave()
    if config.hooks.pre_tab_leave ~= nil then
        config.hooks.pre_tab_leave()
    end
    local tab = vim.api.nvim_get_current_tabpage()
    local buf_nums = utils.get_valid_buffers()
    M.cache[tab] = buf_nums
    for _, k in pairs(buf_nums) do
        vim.api.nvim_buf_set_option(k, "buflisted", false)
    end
    M.last_tab = tab
    if config.hooks.post_tab_leave ~= nil then
        config.hooks.post_tab_leave()
    end
end

function M.on_tab_closed()
    if config.hooks.pre_tab_close ~= nil then
        config.hooks.pre_tab_close()
    end
    M.cache[M.last_tab] = nil
    if config.hooks.post_tab_close ~= nil then
        config.hooks.post_tab_close()
    end
end

function M.revalidate()
    local tab = vim.api.nvim_get_current_tabpage()
    local buf_nums = utils.get_valid_buffers()
    M.cache[tab] = buf_nums
end

function M.print_summary()
    print("tab" .. " " .. "buf" .. " " .. "name")
    for tab, buf_item in pairs(M.cache) do
        for _, buf in pairs(buf_item) do
            local name = vim.api.nvim_buf_get_name(buf)
            print(tab .. " " .. buf .. " " .. name)
        end
    end
end

-- Smart closing of a scoped buffer, this makes sure you only delete a buffer if is not currently open in any other tab.
-- If it is, then we just unlist the buffer.
-- Also if it is the only buffer in the current tab, we close the tab
-- If is not only the only buffer but also the last tab, we ask for permision to close it all
---@param opts table, if buf is not passed we are considering the current buffer
---@param opts.buf integer, if buf is not passed we are considering the current buffer
---@param opts.force boolean, default to true to force close
---@param opts.ask boolean, default to true to ask before closing the last tab ---@diagnostic disable-line
---@return nil
M.close_buffer = function(opts)
    opts = opts or {}
    local current_tab = vim.api.nvim_get_current_tabpage()
    local current_buf = opts.buf or vim.api.nvim_get_current_buf()

    -- Ensure the cache is up-to-date
    M.revalidate()

    local buffers_in_current_tab = M.cache[current_tab]

    -- Check if the buffer exists in other tabs (could be a utils function)
    local buffer_exists_in_other_tabs = false
    for tab, buffers in pairs(M.cache) do
        if tab ~= current_tab then
            for _, buffer in ipairs(buffers) do
                if buffer == current_buf then
                    buffer_exists_in_other_tabs = true
                    break
                end
            end
        end
        if buffer_exists_in_other_tabs then
            break
        end
    end

    -- If the buffer exists in other tabs, hide it in the current tab
    if buffer_exists_in_other_tabs then
        if #buffers_in_current_tab > 1 then
            vim.api.nvim_buf_set_option(current_buf, "buflisted", false)
            vim.cmd([[bprev]])
        else
            vim.cmd("tabclose")
        end
    else -- buffer does not exist in other tabs
        local tab_count = #vim.api.nvim_list_tabpages()
        if #buffers_in_current_tab == 1 then
            if tab_count > 1 then
                vim.api.nvim_buf_delete(current_buf, { force = opts.force })
                vim.cmd("tabclose")
            else
                -- Ask for confirmation before quitting if it's the only tab
                local choice = vim.fn.confirm("You're about to close the last tab. Do you want to quit?", "&Yes\n&No")
                if choice == 1 then
                    vim.cmd("qa!")
                end
            end
        else
            vim.api.nvim_buf_delete(current_buf, { force = opts.force })
        end
    end

    -- Update the cache
    M.revalidate()
end

function M.move_current_buf(opts)
    -- ensure current buflisted
    local buflisted = vim.api.nvim_buf_get_option(0, "buflisted")
    if not buflisted then
        return
    end

    local target = tonumber(opts.args)
    if target == nil then
        -- invalid target tab, get input from user
        local input = vim.fn.input("Move buf to: ")
        if input == "" then -- user cancel
            return
        end

        target = tonumber(input)
    end

    -- bufferline always display  tab number, not the handle. When scope use tab handle to store buffer info. So need to convert
    local target_handle = vim.api.nvim_list_tabpages()[target]

    if target_handle == nil then
        vim.api.nvim_err_writeln("Invalid target tab")
        return
    end

    M.move_buf(vim.api.nvim_get_current_buf(), target_handle)
end

function M.move_buf(bufnr, target)
    -- copy current buf to target tab
    local target_bufs = M.cache[target] or {}
    target_bufs[#target_bufs + 1] = bufnr

    -- remove current buf from current tab if it is not the last one in the tab
    local buf_nums = utils.get_valid_buffers()
    if #buf_nums > 1 then
        vim.api.nvim_buf_set_option(bufnr, "buflisted", false)

        -- current buf are not in the current tab anymore, so we switch to the previous tab
        if bufnr == vim.api.nvim_get_current_buf() then
            vim.cmd("bprevious")
        end
    end
end
return M
