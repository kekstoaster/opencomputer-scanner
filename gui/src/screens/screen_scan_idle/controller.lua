local class = require("class")

local MAX_SIZE = 16

local ScreenScanIdleController, static = class()

function ScreenScanIdleController:new(app)
    self.__app = app

    self.__name = ""
    self.__description = ""

    self.__blocks_map = {
        [2] = 2 * 2 * 2,
        [4] = 4 * 4 * 4,
        [8] = 8 * 8 * 8,
        [16] = 16 * 16 * 16
    }

    self.__time_map = {
        [2] = self.__blocks_map[2] * 1.40625,
        [4] = self.__blocks_map[4] * 1.40625,
        [8] = self.__blocks_map[8] * 1.40625,
        [16] = self.__blocks_map[16] * 1.40625
    }
end

function ScreenScanIdleController:get_size()
    local config = self.__app:get_state("config")
    local size = config:get("model_size")
    -- print("get_size", size.selected, size.max)
    if size.selected == nil then
        return MAX_SIZE
    else
        return size.selected
    end
end

function ScreenScanIdleController:set_size(value)
    local config = self.__app:get_state("config")
    local size = config:get("model_size")
    size.selected = value
    config:save()
end

function ScreenScanIdleController:get_max_size()
    local config = self.__app:get_state("config")
    local size = config:get("model_size")
    -- print("get_max", size.selected, size.max)
    if size.max == nil then
        return MAX_SIZE
    else
        return size.max
    end
end

function ScreenScanIdleController:get_block_count()
    return self.__blocks_map[self:get_size()]
end

function ScreenScanIdleController:get_time_estimate()
    return self.__time_map[self:get_size()]
end

function ScreenScanIdleController:get_name()
    return self.__name
end

function ScreenScanIdleController:set_name(value)
    self.__name = value
end

function ScreenScanIdleController:get_description()
    return self.__description
end

function ScreenScanIdleController:set_description(value)
    self.__description = value
end

function ScreenScanIdleController:get_scanner()
    return self.__app:get_state("scanner")
end

return static
