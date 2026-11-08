local utils = require("scope.utils")
local M = {}

function M.deserialize_state(state)
    local buf_nums = utils.get_valid_buffers()
    for _, k in pairs(buf_nums) do
        vim.bo[k].buflisted = false
    end
    local scope_state = vim.json.decode(state)
    local core = require("scope.core")
    local tabs = vim.api.nvim_list_tabpages()
    local cache = {}
    for i, tab in ipairs(tabs) do
        if scope_state.cache[i] then
            cache[tab] = utils.get_buffer_ids(scope_state.cache[i])
        end
    end
    core.cache = cache
    core.last_tab = tabs[scope_state.last_tab] or vim.api.nvim_get_current_tabpage()
    core.on_tab_enter()
end

function M.serialize_state()
    local core = require("scope.core")
    local tabs = vim.api.nvim_list_tabpages()
    local scope_cache = {}
    for i, tab in ipairs(tabs) do
        scope_cache[i] = utils.get_buffer_names(core.cache[tab] or {})
    end
    local last_tab = 1
    if core.last_tab and vim.api.nvim_tabpage_is_valid(core.last_tab) then
        last_tab = vim.api.nvim_tabpage_get_number(core.last_tab)
    end
    local state = {
        cache = scope_cache,
        last_tab = last_tab,
    }
    return vim.json.encode(state)
end

function M.load_state()
    if vim.g.ScopeState ~= nil then
        M.deserialize_state(vim.g.ScopeState)
    end
end

function M.save_state()
    vim.g.ScopeState = M.serialize_state()
end

return M
