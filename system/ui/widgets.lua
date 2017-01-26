require "util.class"
require "util.ecs"
require "system.system"
local tt = require "util.table" 

class"widgetsSystem" ( "system" )

function widgetsSystem:widgetsSystem()
    system.system(self)
end

local WidgetsSystem = ecs.processingSystem(widgetsSystem()) 

local isWidgets = ecs.requireAll("ui", "widgets")

function WidgetsSystem:Init(root, broker)
    self.root = root
    self.subscriptions = {"MOUSE_POSITION", "MOUSE_LEFT_CLICK", "MOUSE_RIGHT_CLICK"} 
    self.broker = broker
    broker:Subscribe(self, self.subscriptions)
end

function WidgetsSystem:onAddToWorld(w) 
end

function WidgetsSystem:onAdd(e)
    e:Init(self.world, self.broker)
    self.root:SetUi(e.root)
end

function WidgetsSystem:onRemoveFromWorld(w)
    --self.world:removeEntity(defaultWindows)
end

function WidgetsSystem:onRemove(e)
    self.root:RemoveUi(e.root)
end

--function WindowSystem:preProcess(dt)
--end

function WidgetsSystem:process(e, dt)
    local dt = dt
    local mp = self:GetMessageInfo("MOUSE_POSITION")
    local lc = self:GetMessageInfo("MOUSE_LEFT_CLICK")
    local rc = self:GetMessageInfo("MOUSE_RIGHT_CLICK")
    e:process(dt, mp, lc, rc)
end

--function WindowSystem:postProcess(dt)
--end

WidgetsSystem.filter = isWidgets

return WidgetsSystem
