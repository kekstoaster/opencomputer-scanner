local view = require("src/screens/screen_scan_running/view")
local controller = require("src/screens/screen_scan_running/controller")

local function create_screen(app)
    local c = controller(app)
    local v = view(c)
    return v
end


return create_screen
