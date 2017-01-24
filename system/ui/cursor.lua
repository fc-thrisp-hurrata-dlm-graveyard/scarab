require "util.class"
require "util.ecs"
require "util.event"
require "system.system"
require "entity.ui.cursor"

class"CursorPositionSystem" ( "system" )

local CursorPositionSystem = ecs.processingSystem(CursorPositionSystem()) 

local isCursor = ecs.requireAll("ui", "cursor")

function CursorPositionSystem:Init(root, broker)
    system.system(self)
    self.root = root
    self.subscriptions = {"MOUSE_POSITION"} 
    broker:Subscribe(self, self.subscriptions)
end

local defaultCursor = Cursor()

function CursorPositionSystem:onAddToWorld(w)
    w:addEntity(defaultCursor)
end

function CursorPositionSystem:onAdd(e)
    self.root:SetCursor(e.root)
end

function CursorPositionSystem:onRemoveFromWorldd(w)
    w:removeEntity(defaultCursor)
end

function CursorPositionSystem:onRemove(e)
    self.root:RemoveCursor(e.root)
end

function CursorPositionSystem:process(e, dt)
    local position = self:GetMessageInfo("MOUSE_POSITION")
    e:update(position)
end

CursorPositionSystem.filter = isCursor

return CursorPositionSystem
