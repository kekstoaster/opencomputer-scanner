local ScreenScanIdleController = {}
local MAX_SIZE = 16
ScreenScanIdleController["__index"] = ScreenScanIdleController

function ScreenScanIdleController:new (app)
    local o = {}
    o.app = app

    o.name = ""
    o.description = ""

    o.bocks_map = {
        [2]=2*2*2,
        [4]=4*4*4,
        [8]=8*8*8,
        [16]=16*16*16
    }

    o.time_map = {
        [2]=o.bocks_map[2] * 1.40625,
        [4]=o.bocks_map[4] * 1.40625,
        [8]=o.bocks_map[8] * 1.40625,
        [16]=o.bocks_map[16] * 1.40625
    }

    setmetatable(o, ScreenScanIdleController)
    return o
end

function ScreenScanIdleController:get_size()
    local config = self.app:get_state("config")
    local size = config:get("model_size")
    -- print("get_size", size.selected, size.max)
    if size.selected == nil then
        return MAX_SIZE
    else
        return size.selected
    end
end

function ScreenScanIdleController:set_size(value)
    local config = self.app:get_state("config")
    local size = config:get("model_size")
    size.selected = value
    config:save()
end

function ScreenScanIdleController:get_max_size()
    local config = self.app:get_state("config")
    local size = config:get("model_size")
    -- print("get_max", size.selected, size.max)
    if size.max == nil then
        return MAX_SIZE
    else
        return size.max
    end
end

function ScreenScanIdleController:get_block_count()
    return self.bocks_map[self:get_size()]
end

function ScreenScanIdleController:get_time_estimate()
    return self.time_map[self:get_size()]
end

function ScreenScanIdleController:get_name()
    return self.name
end

function ScreenScanIdleController:set_name(value)
    self.name = value
end

function ScreenScanIdleController:get_description()
    return self.description
end

function ScreenScanIdleController:set_description(value)
    self.description = value
end


return ScreenScanIdleController