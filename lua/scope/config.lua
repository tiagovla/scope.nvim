local config = {
    restore_state = false,
}

function config.setup(overrides)
    for k, v in pairs(overrides or {}) do
        config[k] = v
    end
end

return config
