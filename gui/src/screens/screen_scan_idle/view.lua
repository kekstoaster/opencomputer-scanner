local computer = require("computer")
local event = require("event")
local class = require("class")

local Screen = require("gui/screenview")
local Header = require("gui/component/component_header")
local Button = require("gui/component/component_button")
local LabelRow = require("gui/component/component_label_row")
local HorizontalCenter = require("gui/component/component_horizontal_center")
local RadioList = require("gui/component/component_radio_list")

local ScreenScanIdle, static, base = class(Screen)

function ScreenScanIdle:new(controller)
    base.new(self)
    self.__ctrl = controller

    local function format_time(seconds)
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

    local label_expected_time = LabelRow { text = format_time(controller:get_time_estimate()) }
    local label_expected_blocks = LabelRow { text = tostring(controller:get_block_count()) }

    local function select_fn(value)
        controller:set_size(value)
        local blocks = controller:get_block_count()
        local time = controller:get_time_estimate()
        label_expected_blocks:set_text(tostring(blocks))
        label_expected_time:set_text(format_time(time))
    end

    local move = 32

    local radio = RadioList { name = "Size Selector", x = 30 + move, y = 14, spacing = 5, select = select_fn }
    local cur_size = 2
    while cur_size <= controller:get_max_size() do
        radio:add_option(cur_size, cur_size)
        cur_size = cur_size * 2
    end
    radio:select(controller:get_size())

    self:add_component(Header { text = "3D Scanner - Neuer Scan", y = 4 })

    self:add_component(LabelRow { text = "Scan Größe:   ", x = move, y = 14, align = "right", padding = 30, component = radio, name = "row" })

    self:add_component(LabelRow { text = "Benötigte Zeit:   ", x = move, y = 19, align = "right", padding = 30, component = label_expected_time, name = "row" })

    self:add_component(LabelRow { text = "Blöcke:   ", x = move, y = 21, align = "right", padding = 30, component = label_expected_blocks, name = "row" })

    local function scan_fn()
        local scanner = controller:get_scanner()
        scanner:start_scan(controller:get_size())
        event.push("screen", "progress", "progress", "progress")
    end

    local function reset_fn()

    end
    self.__reset_fn = reset_fn

    local btn_save = Button { text = "Scannen", click = scan_fn, padding = 10, name = "btn" }
    local hc_save = HorizontalCenter { component = btn_save, y = 25 }
    self:add_component(hc_save)
end

function ScreenScanIdle:init()
    self.__reset_fn()
end

return static
