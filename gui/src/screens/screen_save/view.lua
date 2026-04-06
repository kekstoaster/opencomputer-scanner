local computer                 = require("computer")
local component                = require("component")
local serialization            = require("serialization")
local thread                   = require("thread")
local event                    = require("event")
local os                       = require("os")

local class                    = require("class")
local Screen                   = require("gui/screenview")
local Header                   = require("gui/component/component_header")
local Button                   = require("gui/component/component_button")
local LabelRow                 = require("gui/component/component_label_row")
local HorizontalCenter         = require("gui/component/component_horizontal_center")
local Input                    = require("gui/component/component_input")
local RadioList                = require("gui/component/component_radio_list")

local ScreenSave, static, base = class(Screen)

function ScreenSave:new(controller)
    base.new(self)

    self.__ctrl = controller
    local move = 33

    self:add_component(Header { text = "3D Scanner - Speichern", y = 4 })

    local scanner = controller:get_scanner()

    local function update_name_fn(value)

    end

    local function update_desc_fn(value)

    end

    local function finish_fn()
        event.push("screen", "setup", "setup", "setup")
    end

    local input_name = Input { name = "Scan Name", size = 30, change = update_name_fn }
    self:add_component(LabelRow { text = "Modelname:   ", x = move, y = 13, align = "right", padding = 30, component = input_name })

    local input_desc = Input { name = "Scan Desc", size = 30, change = update_desc_fn }
    self:add_component(LabelRow { text = "Beschreibung:   ", x = move, y = 17, align = "right", padding = 30, component = input_desc })

    local radio = RadioList { name = "Ziel: ", x = 30 + move, y = 22, spacing = 5 }
    radio:add_option("Server", "server")
    radio:add_option("Diskette", "disk")
    radio:select("server")
    self:add_component(radio)

    local function save_fn()
        if scanner:context().complete then
            if radio:value() == "disk" and not component.disk_drive.isEmpty() then
                local media = component.disk_drive.media()
                local disk_fs = component.proxy(media)

                local f = disk_fs.open("/model.print", "w")
                disk_fs.setLabel(input_name:get_text())
                disk_fs.write(f, serialization.serialize(scanner:context().result))
                disk_fs.close(f)
            end
        end
    end

    self:add_component(Button { text = "Speichern", x = 30 + move, y = 35, click = save_fn, padding = 2, name = "btn" })
    self:add_component(Button { text = "Beenden", x = 50 + move, y = 35, click = finish_fn, padding = 2, name = "btn" })

    self.__reset_fn = function()
        input_name:set_text("")
        input_desc:set_text("")
    end
end

function ScreenSave:init()
    self.__reset_fn()
end

return static
