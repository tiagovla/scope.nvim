local config = require("scope.config")
local core = require("scope.core")
local session = require("scope.session")
local utils = require("scope.utils")

local M = {}

function M._setup_legacy()
    vim.cmd([[
    augroup ScopeAU
        autocmd!
        autocmd TabEnter * lua require("scope.core").on_tab_enter()
        autocmd TabLeave * lua require("scope.core").on_tab_leave()
        autocmd TabClosed * lua require("scope.core").on_tab_closed()
        autocmd TabNewEntered * lua require("scope.core").on_tab_new_entered()
    augroup END
    ]])
end

function M._setup()
    local group = vim.api.nvim_create_augroup("ScopeAU", {})
    vim.api.nvim_create_autocmd("TabEnter", { group = group, callback = core.on_tab_enter })
    vim.api.nvim_create_autocmd("TabLeave", { group = group, callback = core.on_tab_leave })
    vim.api.nvim_create_autocmd("TabClosed", { group = group, callback = core.on_tab_closed })
    vim.api.nvim_create_autocmd("TabNewEntered", { group = group, callback = core.on_tab_new_entered })
    vim.api.nvim_create_user_command("ScopeSaveState", session.save_state, {})
    vim.api.nvim_create_user_command("ScopeLoadState", session.load_state, {})
    vim.api.nvim_create_user_command("ScopeList", core.print_summary, {}) --TODO: improve this
    if config.restore_state then
        -- api.nvim_create_autocmd("SessionLoadPost", { group = group, callback = session.load_state }) --TODO: implement event behavior
    end
end

function M.setup(overrides)
    config.setup(overrides)
    if utils.is_minimum_version(0, 7, 0) then
        M._setup()
    else
        M._setup_legacy()
    end
end

return M
