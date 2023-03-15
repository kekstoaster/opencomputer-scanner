local view = require("src/screens/screen_save/view")
local controller = require("src/screens/screen_save/controller")

function create_screen(app)
    local c = controller:new(app)
    local v = view:new(c)
    return v
end


return create_screen