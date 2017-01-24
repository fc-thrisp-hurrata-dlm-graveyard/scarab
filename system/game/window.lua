require "util.class"
require "util.ecs"
require "util.event"
require "system.system"
local gw = require "entity.game.window"

class"gameWindow" ("system")

function gameWindow:gameWindow()
    system.system(self)
end

local GameWindowSystem = ecs.system(gameWindow()) 

local isGameWindow = ecs.requireAll("game", "window")

function GameWindowSystem:Init(broker, world)
    self.window = GameWindow(broker, world)
end

function GameWindowSystem:Current()
    return self.window:Current()
end

--function GameWindowSystem:onAdd(e)
--end

function GameWindowSystem:onAddToWorld(world)
    world:addEntity(self.window)
end

function GameWindowSystem:onRemove(e)
    self.window = nil
end

function GameWindowSystem:onRemoveFromWorld(world)
    world:removeEntity(self.window)
end

function GameWindowSystem:update(dt)
end

GameWindowSystem.filter = isGameWindow

return GameWindowSystem
