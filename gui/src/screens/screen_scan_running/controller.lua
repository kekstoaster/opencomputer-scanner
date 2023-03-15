local ScreenScanRunningController = {}
ScreenScanRunningController["__index"] = ScreenScanRunningController

function ScreenScanRunningController:new (app)
    local o = {}
    o.app = app



    setmetatable(o, ScreenScanRunningController)
    return o
end

function ScreenScanRunningController:get_scanner(value)
    return self.app:get_state("scanner")
end

return ScreenScanRunningController