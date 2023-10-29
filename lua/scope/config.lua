local config = {
    restore_state = false,
    hooks = {
        pre_tab_enter = nil,
        post_tab_enter = nil,
        pre_tab_leave = nil,
        post_tab_leave= nil,
        pre_tab_close= nil,
        post_tab_close= nil,
    },
}

function config.setup(overrides)
    for k, v in pairs(overrides or {}) do
        config[k] = v
    end
end

return config
