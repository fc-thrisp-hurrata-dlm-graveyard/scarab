require "util.class"
require "util.ecs"
local cps = require "system.ui.cursor"
local wss = require "system.ui.widgets"
--local ws  = require "system.ui.widget"

class"uiSystem"

function uiSystem:uiSystem()
    subsystem = {}
end

local UISystem = ecs.processingSystem(uiSystem()) 

local isUI = ecs.requireAll("ui")

function initSubsystem(root, broker) 
    local ret = {cps, wss}
    for _, v in ipairs(ret) do 
        v:Init(root, broker)
    end
    return ret
end

function UISystem:Init(game)
    local root = game.window.scene
    local broker = game.broker
    self.subsystem = initSubsystem(root, broker)
end

function UISystem:onAddToWorld(world)
    for _, v in ipairs(self.subsystem) do
        world:addSystem(v)
    end
end

function UISystem:onRemoveFromWorld(world)
    for _, v in ipairs(self.subsystem) do
        world:removeSystem(v)
    end
end

function UISystem:process(e, dt)
end

UISystem.filter = isUI

return UISystem
