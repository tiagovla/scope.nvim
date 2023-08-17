local core = require("scope.core")
local session = require("scope.session")

local M = {}

M.on_save = function()
    core.revalidate()
    return { state = session.serialize_state() }
end

M.on_load = function(data)
    session.deserialize_state(data.state)
end

return M
