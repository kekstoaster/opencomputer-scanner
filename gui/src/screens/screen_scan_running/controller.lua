local class = require("class")

local ScreenScanRunningController, static = class()

function ScreenScanRunningController:new(app)
    self.__app = app
end

function ScreenScanRunningController:get_scanner()
    return self.__app:get_state("scanner")
end

return static
