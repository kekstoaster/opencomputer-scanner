local computer = require("computer")
local thread = require("thread")
local event = require("event")
local os  = require("os")

local Screen = require("gui/screenview")
local header = require("gui/component/component_header")
local button = require("gui/component/component_button")
local label_row = require("gui/component/component_label_row")
local horizontal_center = require("gui/component/component_horizontal_center")
local progress_bar = require("gui/component/component_progress_bar")

local ScreenScanRunning = Screen.new()
ScreenScanRunning["__index"] = ScreenScanRunning

function ScreenScanRunning:new (controller)
    local o = {}
    o.ctrl = controller

    setmetatable(o, ScreenScanRunning)

    --local gpu = o.gpu

    o:addComponent(header:new{text="3D Scanner - Scanvorgang", y=4})

    local text_x = label_row:new{text="1"}
    local text_y = label_row:new{text="1"}
    local text_z = label_row:new{text="1"}
    local text_current_block = label_row:new{text=""}
    local text_remaining_blocks = label_row:new{text=""}
    local text_remaining_time = label_row:new{text="unbekannt"}

    local scanner = controller.app:get_state("scanner")

    function format_time(seconds)
        seconds = math.floor(seconds)
        local h = math.floor(seconds / 3600)
        local m = math.floor((seconds % 3600) / 60)
        local s = seconds % 60

        local str = ""
        if h > 0 then
            str = h .. "h "
        end
        if m > 0 then
            str = str .. m .. "m "
        end
        if s > 0 then
            str = str .. s .. "s"
        end
        return str
    end

    function cancel_fn()
        scanner:cancel_scan()
        event.push("screen", "setup", "setup", "setup")
    end

    local move = 50

    o:addComponent(label_row:new{text="Z: ", x=move, y=14, align="right", padding=30, component=text_z, name="row"})
    o:addComponent(label_row:new{text="Y: ", x=move, y=15, align="right", padding=30, component=text_y, name="row"})
    o:addComponent(label_row:new{text="X: ", x=move, y=16, align="right", padding=30, component=text_x, name="row"})


    o:addComponent(label_row:new{text="Block: ", x=move, y=18, align="right", padding=30, component=text_current_block, name="row"})

    o:addComponent(label_row:new{text="Verbleibend: ", x=move, y=20, align="right", padding=30, component=text_remaining_blocks, name="row"})
    o:addComponent(label_row:new{text="Zeit: ", x=move, y=21, align="right", padding=30, component=text_remaining_time, name="row"})


    local btn1 = button:new{text="Abbrechen", click=cancel_fn, padding=5, name="btn"}
    local hc1 = horizontal_center:new{component=btn1, y=30}
    local progress = progress_bar:new{width=51}
    local hc2 = horizontal_center:new{component=progress, y=25}

    o:addComponent(hc1)
    o:addComponent(hc2)


    local update = function(scan_context)
        text_x:set_text(scan_context.x)
        text_y:set_text(scan_context.y)
        text_z:set_text(scan_context.z)
        if scan_context.block ~= nil then
            text_current_block:set_text(scan_context.block.name)
        else
            text_current_block:set_text("")
        end
        text_remaining_blocks:set_text(scan_context.count - scan_context.index)
        if (scan_context.index > 3) then
            local time_avg = scan_context.index / (computer.uptime() - scan_context.start)
            text_remaining_time:set_text(format_time((scan_context.count - scan_context.index) * time_avg))
        end

        progress:advance()
        o.gpu:invalidate()

        if scan_context.count == scan_context.index then
            event.push("screen", "save", "save", "save")
        end
    end

    function reset_fn()
        text_x:set_text(1)
        text_y:set_text(1)
        text_z:set_text(1)
        text_current_block:set_text("")
        text_remaining_blocks:set_text("")
        text_remaining_time:set_text("unbekannt")

        local context = scanner:context()
        progress.max = context.count
        progress:reset()
    end
    o.reset_fn = reset_fn

    scanner:add_update_listener(update)

    return o
end

function ScreenScanRunning:init()
    self:reset_fn()
end

return ScreenScanRunning