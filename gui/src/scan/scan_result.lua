local ScanResult_meta = {}
ScanResult_meta["__index"] = ScanResult_meta
local ScanResult = {}

function ScanResult:new (a)
    local o = {}   -- create object if user does not provide one
    setmetatable(o, ScanResult_meta)
    return o
end



return ScanResult