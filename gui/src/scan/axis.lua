local computer = require("computer")

local Axis_meta = {}
Axis_meta["__index"] = Axis_meta
local Axis = {}


function Axis:new (o)
    o = o or {}   -- create object if user does not provide one
    o.start_position = nil
    setmetatable(o, Axis_meta)
    return o
end

function Axis_meta:is_start_position(force_check)
    local block = self.detect.item.analyze(self.detect.side)
    local identical = identical_blocks(block, self.block)
    --if not force_check and self.start_position ~= nil then
    --    return self.start_position
    --end
    if self.detect_reverse ~= nil then
        self.start_position = not identical
    else
        if identical then
            self.start_position = true
        else
            -- swap blocks
            self.redstone.item.setOutput(self.redstone.side, 15)
            self.detect.item.analyze(self.detect.side)  -- only to skip some time
            -- detect
            block = self.detect.item.analyze(self.detect.side)
            self.redstone.item.setOutput(self.redstone.side, 0)
            self.detect.item.analyze(self.detect.side)  -- only to skip some time
            -- swap back
            self.redstone.item.setOutput(self.redstone.side, 15)
            self.detect.item.analyze(self.detect.side)  -- only to skip some time
            self.redstone.item.setOutput(self.redstone.side, 0)
            self.start_position = not identical_blocks(block, self.block)
        end
    end

    return self.start_position
end

function Axis_meta:is_origin()
    local block = self.detect.item.analyze(self.detect.side)
    local identical = identical_blocks(block, self.block)
    if self.detect_reverse ~= nil then
        return not identical
    else
        if identical then
            return true
        else
            return false
        end
    end
end

function Axis_meta:swap()
    local timeout = 5
    local block = self.detect.item.analyze(self.detect.side)
    local direction = identical_blocks(block, self.block)
    local detection, identical
    local t = computer.uptime()

    self.redstone.item.setOutput(self.redstone.side, 15)

    if direction then
        if self.detect_reverse ~= nil then
            detection = self.detect_reverse
            identical = true
        else
            detection = self.detect
            identical = false
        end
    else
        detection = self.detect
        identical = true
    end

    while true do
        block = detection.item.analyze(detection.side)
        if identical_blocks(block, self.block) == identical then
            break
        end
        if computer.uptime() - t > timeout then
            self.redstone.item.setOutput(self.redstone.side, 0)
            detection.item.analyze(self.detect.side)
            self:swap()
            if self.start_position ~= nil then
                self.start_position = not self.start_position
            end
            break
        end
    end

    self.redstone.item.setOutput(self.redstone.side, 0)
end

function identical_blocks(b1, b2)
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

return Axis