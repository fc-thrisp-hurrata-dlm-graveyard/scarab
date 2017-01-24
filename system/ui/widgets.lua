require "util.class"
require "util.ecs"
require "system.system"
--require "entity.ui.windows"
--require "entity.ui.window" 
--require "entity.ui.osdi"

class"WidgetsSystem" ( "system" )

function WidgetsSystem:WidgetsSystem()
    system.system(self)
end

local WidgetsSystem = ecs.processingSystem(WidgetsSystem()) 

local isWidgets = ecs.requireAll("ui", "widgets")

function WidgetsSystem:Init(root, broker)
    self.root = root
    self.subscriptions = {"MOUSE_POSITION", "MOUSE_LEFT_CLICK", "MOUSE_RIGHT_CLICK"} 
    self.broker = broker
    broker:Subscribe(self, self.subscriptions)
end

--[[local testWidgets = Windows()

local function default(tag, x, y)
    return Window(
        tag,
        Position(x, y),
        Size(25,25),
        Border(1, vec4(0,1,1,1), vec4(.25,0,1,1)),
        Background(vec4(0,0,1,1), vec4(.7,1,0,1)),
        {
            --function(w) print("entered " .. w.tag) end,
            function(w) w.background:onEnter() end,
            function(w) w.border:onEnter() end,
        },
        {
            --function(w) print("exited " .. w.tag) end,
            function(w) w.background:onExit() end,
            function(w) w.border:onExit() end, 
        },
        {
            --function(w) print("left click " .. w.tag) end
        },
        {
            --function(w) print("right click " .. w.tag) end
        }
    )
end]]

--math.randomseed(os.time())

function WidgetsSystem:onAddToWorld(w)
    --self.world:addEntity(testWidgets)
    --for i = 1,10000 do
    --    local nw = default("W-"..i, math.random(-400, 400), math.random(-400, 400))        
    --    self.world:addEntity(nw)
    --    testWidgets.stack:push(nw)
    --end
    --self.world:addEntity(OSDI())
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
