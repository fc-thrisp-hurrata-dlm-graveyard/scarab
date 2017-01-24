require "util.class"
require "util.ecs"
local cps = require "system.ui.cursor"
local wss = require "system.ui.widgets"
--local ws  = require "system.ui.widget"

class"UISystem"

function UISystem:UISystem()
    subsystem = {}
end

local UISystem = ecs.processingSystem(UISystem()) 

local isUI = ecs.requireAll("ui")

function initSubsystem(root, broker) 
    local ret = {cps, wss}
    for _, v in ipairs(ret) do 
        v:Init(root, broker)
    end
    return ret
end

function UISystem:Init(root, broker)
    self.subsystem = initSubsystem(root, broker)
end

function UISystem:onAddToWorld(world)
    for _, v in ipairs(self.subsystem) do
        world:addSystem(v)
    end
end

function UISystem:onRemoveFromWorld(world)
    world:removeEntity(c)
end

function UISystem:process(e, dt)
end

UISystem.filter = isUI

return UISystem
