local view = require("src/screens/screen_scan_running/view")
local controller = require("src/screens/screen_scan_running/controller")

function create_screen(app)
    local c = controller:new(app)
    local v = view:new(c)
    return v
end


return create_screen