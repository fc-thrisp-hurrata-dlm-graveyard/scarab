require "util.class"
require "util.event"
require "util.stack"

class"Windows"

function Windows:Windows()
    self.ui = true
    self.widgets = true
    self.stack = stack()
    self.root = am.translate(0,0):tag("WINDOW-STACK")
end

function Windows:Init(world, broker)
end

local function hovered(mouse, stack)
    local l = stack:list()
    local ret = 10000000
    for _, v in ipairs(l) do
        if v:IsInside(mouse) then
            local p = v.position:z() 
            if p < ret then
                ret = p
            end
        end
    end
    return ret
end

local function reorder(idx, stack)
    local h = stack:pop(idx)
    stack:push(h) 
end

local function iter(idx, dt, left, right, stack)
    local l = stack:list()
    for _, v in ipairs(l) do
        local hover = false
        if v.position:z() == idx then
            hover = true 
        end
        v:process(dt, hover, left, right)
    end
end

local function refresh(node, stack)
    node:remove_all()
    local l = stack:list()
    for i, v in ipairs(l) do
        v.position:update_z(i)
        node:append(v.root)
    end
end

function Windows:process(dt, mouse, left, right)
    local hidx = hovered(mouse, self.stack) 
   
    reorder(hidx, self.stack)

    iter(hidx, dt, right, left, self.stack)
    
    refresh(self.root, self.stack)
end
