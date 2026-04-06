local component = require("component")
local thread = require("thread")
local computer = require("computer")
--local coroutine = require("coroutine")
local os = require("os")

local ah = require("src/scan/axis_helper")
local class = require("class")

local Scanner, static = class()

local exclude = "minecraft:air"

function Scanner:new(base_config, geo_config, redstone_config)
    self.__base = base_config
    self.__geo = geo_config
    self.__redstone = redstone_config
    self.__scan_context = nil
    self.__runner = nil

    self.__block_scanner = component.proxy(geo_config.block.address)
    self.__scanner_side = geo_config.block.side
    self.__listeners = {}

    self.__axis_grid_x = {}
    self.__axis_grid_y = {}
    self.__axis_grid_z = {}

    for i = 1, base_config.model_size.max do
        table.insert(self.__axis_grid_x, ah.create_axis_x(geo_config, redstone_config, i))
        table.insert(self.__axis_grid_y, ah.create_axis_y(geo_config, redstone_config, i))
        table.insert(self.__axis_grid_z, ah.create_axis_z(geo_config, redstone_config, i))
    end
end

function Scanner:add_update_listener(update_cb)
    table.insert(self.__listeners, update_cb)
end

function Scanner:start_scan(shape)
    if self.__scan_context == nil or not self.__scan_context.running then
        self.__scan_context = {
            running = true,
            complete = false,
            canceled = false,
            x = 1,
            y = 1,
            z = 1,
            block = nil,
            size = self.__base.model_size.max,
            shape = shape,
            count = shape * shape * shape,
            index = 0,
            start = computer.uptime(),
            exclude = exclude
        }
        self.__runner = thread.create(Scanner.Scanner_thread, self)
        --self:Scanner_thread()
    end

    return self.__scan_context
end

local function reduce_block(block)
    return {
        name = block.name,
        color = block.color,
        metadata = block.metadata,
        properties = block.properties
    }
end

function Scanner:Scanner_thread()
    os.sleep()
    self:reset_axes()
    local scan_context = self.__scan_context
    scan_context.result = {}
    for z = 1 + (scan_context.size - scan_context.shape), scan_context.size do
        scan_context.z = z
        scan_context.result[z - (scan_context.size - scan_context.shape)] = {}
        os.sleep()
        self.__axis_grid_z[z]:swap()
        os.sleep()
        for y = 1, scan_context.shape do
            scan_context.y = y
            scan_context.result[z - (scan_context.size - scan_context.shape)][y] = {}
            os.sleep()
            self.__axis_grid_y[y]:swap()
            os.sleep()
            for x = 1, scan_context.shape do
                scan_context.x = x
                os.sleep()
                self.__axis_grid_x[x]:swap()
                os.sleep()

                scan_context.block = self:Scanner_read_block()
                os.sleep()
                scan_context.result[z - (scan_context.size - scan_context.shape)][y][x] = scan_context.block
                scan_context.index = scan_context.index + 1

                os.sleep()
                self.__axis_grid_x[x]:swap()
                os.sleep()
                if not scan_context.running then
                    scan_context.canceled = true
                    break
                end

                for i, v in ipairs(self.__listeners) do
                    pcall(v, scan_context)
                    --v(scan_context)
                    os.sleep()
                end
            end
            os.sleep()
            self.__axis_grid_y[y]:swap()
            os.sleep()

            if not scan_context.running then
                scan_context.canceled = true
                break
            end
        end
        os.sleep()
        self.__axis_grid_z[z]:swap()
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

function Scanner:reset_axes()
    local size = self.__base.model_size.max
    for _, addr in ipairs(self.__redstone.address) do
        local proxy = component.proxy(addr)
        for s = 0, 5 do
            os.sleep()
            proxy.setOutput(s, 0)
        end
        os.sleep()
    end


    for i = 1, size do
        local ax = self.__axis_grid_x[i]
        if not ax:is_start_position() then
            os.sleep()
            ax:swap()
            break
        end
        os.sleep()
    end

    for i = 1, size do
        local ax = self.__axis_grid_y[i]
        if not ax:is_start_position() then
            os.sleep()
            ax:swap()
            break
        end
        os.sleep()
    end

    for i = 1, size do
        local ax = self.__axis_grid_z[i]
        if not ax:is_start_position() then
            os.sleep()
            ax:swap()
            break
        end
        os.sleep()
    end
end

function Scanner:Scanner_read_block()
    local scan_context = self.__scan_context
    os.sleep()
    local block = self.__block_scanner.analyze(self.__scanner_side)
    os.sleep()

    if (block.name ~= exclude) then
        return reduce_block(block)
    else
        return nil
    end
end

function Scanner:cancel_scan()
    self.__scan_context.running = false
    -- self.__scan_context = nil
end

function Scanner:is_ready()
    return false
end

function Scanner:is_running()
    if self.__scan_context then
        return not self.__scan_context.complete
    end
    return false
end

function Scanner:context()
    return self.__scan_context
end

return static
