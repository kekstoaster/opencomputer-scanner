local component = require("component")
local Axis = require("src/scan/axis")

function create_axis_z(geo, redstone, n)
    return Axis:new{
        redstone={
            side=redstone.side[1],
            item=component.proxy(redstone.address[n])
        },
        detect={
            side=geo.vertical.side,
            item=component.proxy(geo.vertical.address[n])
        },
        block=geo.area.block,
        detect_reverse={
            side=geo.area.side,
            item=component.proxy(geo.area.address)
        }
    }
end

function create_axis_y(geo, redstone, n)
    return Axis:new{
        redstone={
            side=redstone.side[2],
            item=component.proxy(redstone.address[n])
        },
        detect={
            side=geo.horizontal.side,
            item=component.proxy(geo.horizontal.address[n])
        },
        block=geo.row.block,
        detect_reverse={
            side=geo.row.side,
            item=component.proxy(geo.row.address)
        },
    }
end

function create_axis_x(geo, redstone, n)
    return Axis:new{
        redstone={
            side=redstone.side[3],
            item=component.proxy(redstone.address[n])
        },
        block=geo.block.block,
        detect={
            side=geo.block.side,
            item=component.proxy(geo.block.address)
        }
    }
end

return {
    create_axis_z=create_axis_z,
    create_axis_y=create_axis_y,
    create_axis_x=create_axis_x
}