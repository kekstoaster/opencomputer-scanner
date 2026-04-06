local class = require("class")
local computer = require("computer")

local Axis, static = class()

local function identical_blocks(b1, b2)
    -- name, metadata, properties
    --print(b1.name, b2.name)
    if b1.name ~= b2.name then
        return false
    end

    if b1.color ~= b2.color then
        return false
    end

    --print(b1.metadata, b2.metadata)
    if b1.metadata ~= b2.metadata then
        return false
    end

    for k, v in pairs(b1.properties) do
        --print("--", k, v, b2.properties[k])
        if b2.properties[k] ~= v then
            return false
        end
    end
    return true
end


function Axis:new(params)
    params = params or {}
    self.__redstone = params.redstone
    self.__detect = params.detect
    self.__block = params.block
    self.__detect_reverse = params.detect_reverse
    self.__start_position = nil
end

function Axis:is_start_position(force_check)
    local block = self.__detect.item.analyze(self.__detect.side)
    local identical = identical_blocks(block, self.__block)
    --if not force_check and self.__start_position ~= nil then
    --    return self.__start_position
    --end
    if self.__detect_reverse ~= nil then
        self.__start_position = not identical
    else
        if identical then
            self.__start_position = true
        else
            -- swap blocks
            self.__redstone.item.setOutput(self.__redstone.side, 15)
            self.__detect.item.analyze(self.__detect.side) -- only to skip some time
            -- detect
            block = self.__detect.item.analyze(self.__detect.side)
            self.__redstone.item.setOutput(self.__redstone.side, 0)
            self.__detect.item.analyze(self.__detect.side) -- only to skip some time
            -- swap back
            self.__redstone.item.setOutput(self.__redstone.side, 15)
            self.__detect.item.analyze(self.__detect.side) -- only to skip some time
            self.__redstone.item.setOutput(self.__redstone.side, 0)
            self.__start_position = not identical_blocks(block, self.__block)
        end
    end

    return self.__start_position
end

function Axis:is_origin()
    local block = self.__detect.item.analyze(self.__detect.side)
    local identical = identical_blocks(block, self.__block)
    if self.__detect_reverse ~= nil then
        return not identical
    else
        if identical then
            return true
        else
            return false
        end
    end
end

function Axis:swap()
    local timeout = 5
    local max_retries = 3

    for attempt = 1, max_retries do
        local block = self.__detect.item.analyze(self.__detect.side)
        local direction = identical_blocks(block, self.__block)
        local detection, identical
        local t = computer.uptime()

        self.__redstone.item.setOutput(self.__redstone.side, 15)

        if direction then
            if self.__detect_reverse ~= nil then
                detection = self.__detect_reverse
                identical = true
            else
                detection = self.__detect
                identical = false
            end
        else
            detection = self.__detect
            identical = true
        end

        local success = false
        while true do
            block = detection.item.analyze(detection.side)
            if identical_blocks(block, self.__block) == identical then
                success = true
                break
            end
            if computer.uptime() - t > timeout then
                self.__redstone.item.setOutput(self.__redstone.side, 0)
                detection.item.analyze(self.__detect.side)
                break
            end
        end

        self.__redstone.item.setOutput(self.__redstone.side, 0)

        if success then
            return
        end
    end
end

return static
