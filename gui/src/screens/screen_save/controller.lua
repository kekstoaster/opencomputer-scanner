local class = require("class")

local ScreenSaveController, static = class()

function ScreenSaveController:new(app)
    self.__app = app
end

function ScreenSaveController:get_scanner()
    return self.__app:get_state("scanner")
end

return static
