local view = require("src/screens/screen_scan_idle/view")
local controller = require("src/screens/screen_scan_idle/controller")

local function create_screen(app)
    local c = controller(app)
    local v = view(c)
    return v
end


return create_screen
