local view = require("src/screens/screen_save/view")
local controller = require("src/screens/screen_save/controller")

local function create_screen(app)
    local c = controller(app)
    local v = view(c)
    return v
end


return create_screen
