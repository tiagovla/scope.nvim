local core = require "scope.core"
local api = vim.api

M = {}

function M.setup()
    local group = "ScopeAU"
    api.nvim_create_augroup("ScopeAU", {})
    api.nvim_create_autocmd("TabEnter", { group = group, callback = core.on_tab_enter })
    api.nvim_create_autocmd("TabLeave", { group = group, callback = core.on_tab_leave })
    api.nvim_create_autocmd("TabClosed", { group = group, callback = core.on_tab_closed })
    api.nvim_add_user_command("ScopeList", core.print_summary, {})
end

return M
