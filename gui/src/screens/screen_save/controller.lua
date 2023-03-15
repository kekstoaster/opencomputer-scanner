local ScreenSaveController = {}
ScreenSaveController["__index"] = ScreenSaveController

function ScreenSaveController:new (app)
    local o = {}
    o.app = app



    setmetatable(o, ScreenSaveController)
    return o
end

function ScreenSaveController:get_scanner()
    return self.app:get_state("scanner")
end

return ScreenSaveController