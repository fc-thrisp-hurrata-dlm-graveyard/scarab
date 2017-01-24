require "util.ecs"
local gw = require "system.game.window"
local gi = require "system.game.input"
local ui = require "system.ui.ui"

local function initialize(game)
    local broker = game.broker

    local world = ecs.world()

    -- game window system
    gw:Init(broker, world)
    world:addSystem(gw)
   
    -- local window variables
    --local window = gw:Current()
    --local root = window.scene 

    -- game input system
    --gi:Init(window, broker)
    --world:addSystem(gi)

    -- ui system
    --ui:Init(root, broker)
    --world:addSystem(ui)

    return world
end

return {
    Init = initialize
}
