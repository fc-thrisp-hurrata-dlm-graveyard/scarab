require "util.class"
require "util.buffer"
local t = require "util.table"

class("Event")

local function wrap(fn)
    return coroutine.wrap(
        function()
            while true do
                if fn then
                    local ok, err = xpcall(fn, debug.traceback)
                    if not ok then print(err) end
                end
                coroutine.yield()
            end
        end
    )
end

function Event:Event(tag, ...)
    self.tag = tag
    self.actions = {}
    local actions = {...}
    for _, v in ipairs(actions) do 
        table.insert(self.actions, wrap(v))    
    end
end

function Event:Execute()
    coroutine.wrap(
        function()
            for _, v in ipairs(self.actions) do
                v()
            end
            coroutine.yield()
        end 
    )()
end

class("Eventer")

function Eventer:Eventer(buffer, ...)
    self.buffer = buffer or puffer()
    self.has = {}
    self:Set({...})
end

function Eventer:Execute(e)
    local b = self.buffer
    local event = b(e) 
    coroutine.wrap(
        function()
            local clear = false
            
            local ev = self:Get(event)
            
            if #ev>0 then clear = true end
            
            for _, v in ipairs(ev) do
                v:Execute()
            end
            
            if clear then
                self.buffer:clear()
            end
            
            coroutine.yield()
        end 
    )()
end

function Eventer:Set(t)
    for _, v in ipairs(t) do
        table.insert(self.has, v)
    end
end

local function funcFilter(t, filter, action)
    for i, v in ipairs(t) do
        if filter(v) then 
            action(t, i, v)
        end
    end
end

local function getFuncs(t, ff)
    local out = {} 
    funcFilter(
        t,
        ff,
        function(t, i, v)
           table.insert(out, v) 
        end
    )
    return out
end

-- TODO: match on pattern or partial for grouping by 1 tag, e.g. "group.subgroup.tag"
function Eventer:Get(key)
    return getFuncs(
        self.has,
        function(kf)
            if kf.tag == key then
                return true
            end
        end
    )
end

function Eventer:Remove(...)
    local tags = {...}
    for _, tag in ipairs(tags) do
        funcFilter(
            self.has,
            function(kf) if kf.tag == tag then return true end end, 
            function(t, i, v) table.remove(t, i) end 
        )
    end
end
