require "util.class"
require "util.ecs"
require "util.event"
require "system.system"
local gi = require "entity.game.input"

class"gameInputSystem" ("system")

function gameInputSystem:gameInputSystem()
    system.system(self)
end

local GameInputSystem = ecs.system(gameInputSystem()) 

local isGameInput = ecs.requireAll("game", "input")

function GameInputSystem:Init(game)
    --self.default = gi.Init(window, broker, world) 
end

function GameInputSystem:onAddToWorld(world)
    --local defaults = self.default.has
    --for _, v in ipairs(defaults) do
    --    world:addEntity(v)
    --end
end

function GameInputSystem:onRemoveFromWorld(world)
    --local defaults = self.default.has
    --for _, v in ipairs(defaults) do
    --    world:removeEntity(self.default)
    --end
end

--function GameInputSystem:update(dt)
--end

GameInputSystem.filter = isGameInput

return GameInputSystem
