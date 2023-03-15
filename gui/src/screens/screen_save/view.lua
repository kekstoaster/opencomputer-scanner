local computer = require("computer")
local component = require("component")
local serialization = require("serialization")
local thread = require("thread")
local event = require("event")
local os  = require("os")

local Screen = require("gui/screenview")
local header = require("gui/component/component_header")
local button = require("gui/component/component_button")
local label_row = require("gui/component/component_label_row")
local horizontal_center = require("gui/component/component_horizontal_center")
local input = require("gui/component/component_input")
local radio_list = require("gui/component/component_radio_list")

local ScreenSave = Screen.new()
ScreenSave["__index"] = ScreenSave

function ScreenSave:new (controller)
    local o = {}
    o.ctrl = controller
    local move = 33

    setmetatable(o, ScreenSave)

    o:addComponent(header:new{text="3D Scanner - Speichern", y=4})

    local scanner = controller.app:get_state("scanner")

    function update_name_fn(value)

    end

    function update_desc_fn(value)

    end

    function finish_fn()
        event.push("screen", "setup", "setup", "setup")
    end

    local input_name = input:new{name="Scan Name", size=30, change=update_name_fn}
    o:addComponent(label_row:new{text="Modelname:   ", x=move, y=13, align="right", padding=30, component=input_name})

    local input_desc = input:new{name="Scan Desc", size=30, change=update_desc_fn}
    o:addComponent(label_row:new{text="Beschnreibung:   ", x=move, y=17, align="right", padding=30, component=input_desc})

    local radio = radio_list:new{name="Ziel: ", x=30 + move, y=22, spacing=5}
    radio:add_option("Server", "server")
    radio:add_option("Diskette", "disk")
    radio:select("server")
    o:addComponent(radio)

    function save_fn()
        if scanner:context().complete then
            if radio:value() == "disk" and not component.disk_drive.isEmpty() then
                local media = component.disk_drive.media()
                local disk_fs = component.proxy(media)

                f = disk_fs.open("/model.print", "w")
                disk_fs.setLabel(input_name:get_text())
                disk_fs.write(f, serialization.serialize(scanner:context().result))
                disk_fs.close(f)
            end
        end
    end

    o:addComponent(button:new{text="Speichern", x=30 + move, y=35, click=save_fn, padding=2, name="btn"})
    o:addComponent(button:new{text="Beenden", x=50 + move, y=35, click=finish_fn, padding=2, name="btn"})

    function reset_fn()
        input_name:set_text("")
        input_desc:set_text("")
    end
    o.reset_fn = reset_fn

    return o
end

function ScreenSave:init()
    self:reset_fn()
end

return ScreenSave