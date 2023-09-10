local utils = require("scope.utils")
local M = {}

function M.deserialize_state(state)
    local buf_nums = utils.get_valid_buffers()
    for _, k in pairs(buf_nums) do --FIX: this might not be required
        vim.api.nvim_buf_set_option(k, "buflisted", false)
    end
    local scope_state = vim.json.decode(state)
    local cache = {}
    for _, table in pairs(scope_state.cache) do
        cache[#cache + 1] = utils.get_buffer_ids(table)
    end
    require("scope.core").cache = cache
    require("scope.core").last_tab = scope_state.last_tab
    require("scope.core").on_tab_enter()
end

function M.serialize_state()
    local core = require("scope.core")
    local scope_cache = {}
    for _, table in pairs(core.cache) do
        scope_cache[#scope_cache + 1] = utils.get_buffer_names(table)
    end
    local state = {
        cache = scope_cache,
        last_tab = core.last_tab,
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
