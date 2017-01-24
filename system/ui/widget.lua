--[[require "util.class"
--require "system.system"
require "ecs"

class"WidgetSystem" --( "system" )

local WidgetSystem = ecs.system(WidgetSystem()) 

local isWidget = ecs.requireAll("ui", "widget")

function WidgetSystem:Init(root, broker)
    --system.system(self)
    --self.root = root
    --self.subscriptions = {"MOUSE_POSITION", "MOUSE_LEFT_CLICK", "MOUSE_RIGHT_CLICK"} 
    --self.messages = {}
    --broker:Subscibe(self, self.subscriptions)
end

--function WidgetSystem:onAddToWorld(w)
--end

--function WidgetSystem:onAdd(e)
--end

--function WidgetSystem:onRemoveFromWorld(w)
--end

--function WidgetSystem:onRemove(e)
--end

--function WidgetSystem:preProcess(dt)
--end

function WidgetSystem:update(dt)
end

--function WidgetSystem:process(e, dt)
    --local dt = dt
    --local mp = self:GetMessageInfo("MOUSE_POSITION")
    --local lc = self:GetMessageInfo("MOUSE_LEFT_CLICK")
    --local rc = self:GetMessageInfo("MOUSE_RIGHT_CLICK")
    --e:process(dt, mp, lc, rc)
--end

--function WidgetSystem:postProcess(dt)
--end

WidgetSystem.filter = isWidget

return WidgetSystem]]
