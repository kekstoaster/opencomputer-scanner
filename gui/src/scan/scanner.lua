local component = require("component")
local thread = require("thread")
local computer = require("computer")
--local coroutine = require("coroutine")
local os = require("os")

local ah = require("src/scan/axis_helper")

local Scanner_meta = {}
Scanner_meta["__index"] = Scanner_meta
local Scanner = {}

local exclude = "minecraft:air"

function Scanner:new (base_config, geo_config, redstone_config)
    local o = {}   -- create object if user does not provide one
    o.base = base_config
    o.geo = geo_config
    o.redstone = redstone_config
    o.scan_context = nil
    o.runner = nil

    o.block_scanner = component.proxy(geo_config.block.address)
    o.scanner_side = geo_config.block.side
    o.listeners = {}

    o.axis_grid_x = {}
    o.axis_grid_y = {}
    o.axis_grid_z = {}

    for i = 1,base_config.model_size.max do
        table.insert(o.axis_grid_x, ah.create_axis_x(geo_config, redstone_config, i))
        table.insert(o.axis_grid_y, ah.create_axis_y(geo_config, redstone_config, i))
        table.insert(o.axis_grid_z, ah.create_axis_z(geo_config, redstone_config, i))
    end

    setmetatable(o, Scanner_meta)
    return o
end

function Scanner_meta:add_update_listener(update_cb)
    table.insert(self.listeners, update_cb)
end

function Scanner_meta:start_scan(shape)
    if self.scan_context == nil or not self.scan_context.running then
        self.scan_context = {
            running=true,
            complete=false,
            canceled=false,
            x=1,
            y=1,
            z=1,
            block=nil,
            size=self.base.model_size.max,
            shape=shape,
            count=shape*shape*shape,
            index=0,
            start=computer.uptime(),
            exclude=exclude
        }
        self.runner = thread.create(Scanner_meta.Scanner_thread, self)
        --self:Scanner_thread()
    end

    return self.scan_context
end

function Scanner_meta:Scanner_thread()
    os.sleep()
    self:reset_axes()
    local scan_context = self.scan_context
    scan_context.result = {}
    for z = 1 + (scan_context.size - scan_context.shape), scan_context.size do
        scan_context.z = z
        scan_context.result[z - (scan_context.size - scan_context.shape)] = {}
        os.sleep()
        self.axis_grid_z[z]:swap()
        os.sleep()
        for y = 1,scan_context.shape do
            scan_context.y = y
            scan_context.result[z - (scan_context.size - scan_context.shape)][y] = {}
            os.sleep()
            self.axis_grid_y[y]:swap()
            os.sleep()
            for x = 1,scan_context.shape do
                scan_context.x = x
                os.sleep()
                self.axis_grid_x[x]:swap()
                os.sleep()

                scan_context.block = self:Scanner_read_block()
                os.sleep()
                scan_context.result[z - (scan_context.size - scan_context.shape)][y][x] = scan_context.block
                scan_context.index = scan_context.index + 1

                os.sleep()
                self.axis_grid_x[x]:swap()
                os.sleep()
                if not scan_context.running then
                    scan_context.canceled = true
                    break
                end

                for i, v in ipairs(self.listeners) do
                    pcall(v, scan_context)
                    --v(scan_context)
                    os.sleep()
                end
            end
            os.sleep()
            self.axis_grid_y[y]:swap()
            os.sleep()

            if not scan_context.running then
                scan_context.canceled = true
                break
            end
        end
        os.sleep()
        self.axis_grid_z[z]:swap()
        os.sleep()

        if not scan_context.running then
            scan_context.canceled = true
            break
        end
    end

    if not scan_context.canceled then
        scan_context.complete = true
    end

    scan_context.running = false
end

function Scanner_meta:reset_axes()
    local size = self.base.model_size.max
    for i, v in ipairs(self.redstone) do
        for s = 0,5 do
            os.sleep()
            v.setOutput(s, 0)
        end
        os.sleep()
    end


    for i = 1,size do
        local ax = self.axis_grid_x[i]
        if not ax:is_start_position() then
            os.sleep()
            ax:swap()
            break
        end
        os.sleep()
    end

    for i = 1,size do
        local ax = self.axis_grid_y[i]
        if not ax:is_start_position() then
            os.sleep()
            ax:swap()
            break
        end
        os.sleep()
    end

    for i = 1,size do
        local ax = self.axis_grid_z[i]
        if not ax:is_start_position() then
            os.sleep()
            ax:swap()
            break
        end
        os.sleep()
    end
end

function reduce_block(block)
    return {
        name=block.name,
        color=block.color,
        metadata=block.metadata,
        properties=block.properties
    }
end

function Scanner_meta:Scanner_read_block()
    local scan_context = self.scan_context
    os.sleep()
    local block = self.block_scanner.analyze(self.scanner_side)
    os.sleep()

    if (block.name ~= exclude) then
        return reduce_block(block)
    else
        return nil
    end
end

function Scanner_meta:cancel_scan()
    self.scan_context.running = false
    -- self.scan_context = nil
end

function Scanner_meta:is_ready()
    return false
end

function Scanner_meta:is_running()
    if self.scan_context then
        return not self.scan_context.complete
    end
    return false
end

function Scanner_meta:context()
    return self.scan_context
end

return Scanner