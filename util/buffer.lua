require "util.class"
local t = require "util.table"

-- interface
-- buffer 
-- buffer:update(multi item)
-- buffer:get(idx)
-- buffer:clear()
-- buffer:_call(item)
-- buffer:list()

-- an infinite(ish) buffer
class"iuffer"

function iuffer:iuffer()
    self.entries = {}
end

function iuffer:update(t)
    for _, v in ipairs(t) do 
        self:_append(v)
    end
end

function iuffer:_append(entry)
    table.insert(self.entries, entry)
end

function iuffer:get(idx)
    if idx < 0 then
        idx = (#self.entries + idx) + 1
    end

    return self.entries[idx]
end

function iuffer:clear()
    self.entries = {}
end

function iuffer:_call()
    self:update(t)
end

function iuffer:list()
    return self.entries
end

--a circular buffer
class("cuffer")

function cuffer:cuffer(max)
    local o = {}
    self.entries = o 
    self.count = #o
    self.cursor = #o + 1
    self.max = max or 50
end

function cuffer:update(t)
    for _, v in ipairs(t) do 
        self:_append(v)
    end
end

function cuffer:_append(entry)
    if entry ~= "" then
        if self.entries[self.cursor] then
            self.entries[self.cursor] = entry
        else
            table.insert(self.entries, entry)
        end
        self.cursor = self.cursor + 1
        if self.cursor == self.max + 1 then
            self.cursor = 1
        end
        if self.count ~= self.max then
            self.count = self.count + 1
        end
    end
end

function cuffer:get(idx)
    if idx < 0 then
        idx = (self.count + idx) + 1
    end

    if self.count == self.max then
        local c = self.cursor + idx - 1
        if c > self.max then
            c = c - self.max
        end
        return self.entries[c]
    else
        return self.entries[idx]
    end
end

function cuffer:clear()
    local o = {}
    self.entries = o
    self.count = #o
    self.cursor = #o + 1
end

function cuffer:_call(t)
    self:update(t)
end

function cuffer:list()
    return self.entries
end

--an absolute buffer
class("auffer")

function auffer:auffer(tag)
    self.tag = tag
end

function auffer:update(action)
end

function auffer:get(idx)
end

function auffer:clear()
end

function auffer:__call(action)
    return self.tag
end

function auffer:list()
end

--a pass through buffer, callable only
class("puffer")

function puffer:puffer()
end

function puffer:update(action)
end

function puffer:get(idx)
end

function puffer:clear()
end

function puffer:__call(action)
    return action
end

function puffer:list()
end

--a timed chaining buffer receiving a table, usually keypresses 
class("chain")

function chain:chain(expiry)
    local x = expiry or 1
    local current = am.current_time()
    self.has = {}
    self.expiry = x 
    self.expires = current+x
    self.expired = false
end

local function chainPop(t)
    local ret = ""
    for _, v in ipairs(t) do
        ret = ret .. v
    end
    return ret
end

function chain:update(action)
    local a = chainPop(action) 
    if a ~= "" then
        table.insert(self.has, a)
    end 
    local current = am.current_time()
    if current >= self.expires then
        self.expired = true
        self:clear()
    end
end

function chain:get(idx)
    return self.has[idx]
end

function chain:clear()
    local current = am.current_time()
    self.has = {}
    self.expires = current + self.expiry
    self.expired = false
end

function chain:__call(action)
    self:update(action)
    return chainPop(self.has)
end

function chain:list()
    return self.has
end
