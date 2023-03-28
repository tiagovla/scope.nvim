local utils = require "scope.utils"
local M = {}

function M.load_session()
    if vim.g.ScopeState == nil then
        return
    end
    local buf_nums = utils.get_valid_buffers()
    for _, k in pairs(buf_nums) do
        vim.api.nvim_buf_set_option(k, "buflisted", false)
    end
    local scope_state = vim.json.decode(vim.g.ScopeState)
    local cache = {}
    for _, table in pairs(scope_state.cache) do
       cache[#cache+1] = utils.get_buffer_ids(table)
    end
    require "scope.core".cache = cache
    require "scope.core".last_tab = scope_state.last_tab
    require "scope.core".on_tab_enter()
end

function M.save_session()
    local core = require "scope.core"
    local scope_cache = {}
    for k, v in pairs(core.cache) do
        scope_cache[k] = utils.get_buffer_names(v)
    end
    local state = {
        cache = scope_cache,
        last_tab = core.last_tab,
    }
    vim.g.ScopeState = vim.json.encode(state)
end

return M
