local event = require("event")
local component = require("component")
local shell = require("shell")

local Scanner = require("src/scan/scanner")
local ScreenScanIdle = require("src/screens/screen_scan_idle/index")
local ScreenScanRunning = require("src/screens/screen_scan_running/index")
local ScreenSave = require("src/screens/screen_save/index")
local border_box = require("gui/border_box")
local GuiApp = require("gui/app")
local FileMirror = require("gui/file_mirror")

local config = FileMirror(shell.getWorkingDirectory() .. "/config")
local geo = require("geo_config")
local redstone = require("redstone_config")

-- component.gpu.setResolution(80, 30)
local scanner = Scanner:new(config:dump(), geo, redstone)

function loop(app)
    --print("loop")
    --print(scanner.)
end

local app = GuiApp:new({loop=loop})
app:set_state("config", config)
app:set_state("scanner", scanner)

screenIdle = ScreenScanIdle(app)
screenRunning = ScreenScanRunning(app)
screenSave = ScreenSave(app)

app:add_screen("setup", screenIdle)
app:add_screen("progress", screenRunning)
app:add_screen("save", screenSave)
--screenIdle:render()

--border_box.render_box_single(3, 5, 10, 3)

--border_box.render_box_double(5, 15, 20, 8)

--print("← ↖ ↑ ↗ → ↘ ↓ ↙")
--print("│ ─  ┘ └ ┌ ┐  ┤ ┴ ├ ┬  ┼")
--print("║ ═  ╝ ╚ ╔ ╗  ╣ ╩ ╠ ╦  ╬")
--print("× ░ ▒ ▓ █ ▄ ▀ ■")


app:run()

w, h = component.gpu.maxResolution()
component.gpu.setResolution(w, h)