local computer = require("computer")
local event = require("event")

local Screen = require("gui/screenview")
local header = require("gui/component/component_header")
local button = require("gui/component/component_button")
local label_row = require("gui/component/component_label_row")
local horizontal_center = require("gui/component/component_horizontal_center")
local radio_list = require("gui/component/component_radio_list")

local ScreenScanIdle = Screen.new()
ScreenScanIdle["__index"] = ScreenScanIdle

function ScreenScanIdle:new (controller)
    local o = {}
    o.ctrl = controller

    setmetatable(o, ScreenScanIdle)

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

    local label_expected_time = label_row:new{text=format_time(controller:get_time_estimate())}
    local label_expected_blocks = label_row:new{text=tostring(controller:get_block_count())}

    function select_fn(value)
        controller:set_size(value)
        local blocks = controller:get_block_count()
        local time = controller:get_time_estimate()
        label_expected_blocks:set_text(tostring(blocks))
        label_expected_time:set_text(format_time(time))
    end

    local move = 32

    local radio = radio_list:new{name="Size Selector", x=30 + move, y=14, spacing=5, select=select_fn}
    local cur_size = 2
    local max_size = controller:get_max_size()
    -- print("max_size", max_size)
    while cur_size <= controller:get_max_size() do
        radio:add_option(cur_size, cur_size)
        cur_size = cur_size * 2
    end
    radio:select(controller:get_size())

    o:addComponent(header:new{text="3D Scanner - Neuer Scan", y=4})

    o:addComponent(label_row:new{text="Scan Größe:   ", x=move, y=14, align="right", padding=30, component=radio, name="row"})

    o:addComponent(label_row:new{text="Benötigte Zeit:   ", x=move, y=19, align="right", padding=30, component=label_expected_time, name="row"})


    o:addComponent(label_row:new{text="Blöcke:   ", x=move, y=21, align="right", padding=30, component=label_expected_blocks, name="row"})



    function scan_fn()
        local scanner = controller.app:get_state("scanner")
        event.push("screen", "progress", "progress", "progress")
        scanner:start_scan(controller:get_size())
    end

    function reset_fn()

    end
    o.reset_fn = reset_fn

    local btn_save = button:new{text="Scannen", click=scan_fn, padding=10, name="btn"}
    local hc_save = horizontal_center:new{component=btn_save, y=25}
    o:addComponent(hc_save)

    return o
end

function ScreenScanIdle:init()
    self:reset_fn()
end

return ScreenScanIdle