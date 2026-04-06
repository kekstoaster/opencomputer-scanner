local computer                        = require("computer")
local thread                          = require("thread")
local event                           = require("event")
local os                              = require("os")

local class                           = require("class")
local Screen                          = require("gui/screenview")
local Header                          = require("gui/component/component_header")
local Button                          = require("gui/component/component_button")
local LabelRow                        = require("gui/component/component_label_row")
local HorizontalCenter                = require("gui/component/component_horizontal_center")
local ProgressBar                     = require("gui/component/component_progress_bar")

local ScreenScanRunning, static, base = class(Screen)

function ScreenScanRunning:new(controller)
    base.new(self)

    self.__ctrl = controller

    self:add_component(Header { text = "3D Scanner - Scanvorgang", y = 4 })

    local text_x = LabelRow { text = "1" }
    local text_y = LabelRow { text = "1" }
    local text_z = LabelRow { text = "1" }
    local text_current_block = LabelRow { text = "" }
    local text_remaining_blocks = LabelRow { text = "" }
    local text_remaining_time = LabelRow { text = "unbekannt" }

    local scanner = controller:get_scanner()

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

    local function cancel_fn()
        scanner:cancel_scan()
        event.push("screen", "setup", "setup", "setup")
    end

    local move = 50

    self:add_component(LabelRow { text = "Z: ", x = move, y = 14, align = "right", padding = 30, component = text_z, name = "row" })
    self:add_component(LabelRow { text = "Y: ", x = move, y = 15, align = "right", padding = 30, component = text_y, name = "row" })
    self:add_component(LabelRow { text = "X: ", x = move, y = 16, align = "right", padding = 30, component = text_x, name = "row" })


    self:add_component(LabelRow { text = "Block: ", x = move, y = 18, align = "right", padding = 30, component = text_current_block, name = "row" })

    self:add_component(LabelRow { text = "Verbleibend: ", x = move, y = 20, align = "right", padding = 30, component = text_remaining_blocks, name = "row" })
    self:add_component(LabelRow { text = "Zeit: ", x = move, y = 21, align = "right", padding = 30, component = text_remaining_time, name = "row" })


    local btn1 = Button { text = "Abbrechen", click = cancel_fn, padding = 5, name = "btn" }
    local hc1 = HorizontalCenter { component = btn1, y = 30 }
    local progress = ProgressBar { width = 51 }
    local hc2 = HorizontalCenter { component = progress, y = 25 }

    self:add_component(hc1)
    self:add_component(hc2)


    local function update(scan_context)
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
            local seconds_per_block = (computer.uptime() - scan_context.start) / scan_context.index
            text_remaining_time:set_text(format_time((scan_context.count - scan_context.index) * seconds_per_block))
        end

        progress:advance()
        self:get_gpu():invalidate()

        if scan_context.count == scan_context.index then
            event.push("screen", "save", "save", "save")
        end
    end

    local function reset_fn()
        text_x:set_text(1)
        text_y:set_text(1)
        text_z:set_text(1)
        text_current_block:set_text("")
        text_remaining_blocks:set_text("")
        text_remaining_time:set_text("unbekannt")

        local context = scanner:context()
        progress:set_max(context.count)
        progress:reset()
    end
    self.__reset_fn = reset_fn

    scanner:add_update_listener(update)
end

function ScreenScanRunning:init()
    self.__reset_fn()
end

return static
