require "util.class"
require "util.event"
require "system.system"
local tt = require "util.table"

class("Font")

function Font:Font(font, size) 
   self.font = font or nil
   self.size = size or 16 
end

local DefaultFont = Font()

class("Noder")

function Noder:Noder(font, justify, color, hoffset)
    self.font = font or DefaultFont
    self.justify = justify or "left"
    self.color = color or vec4(1, 0, 0, 1) 
    self.hoffset = hoffset or 125
end

local function txtnd(n, tag, fn)
    local f = n.font
    if f.font ~= nil then
        return am.text(n.font, fn(), n.color, n.justify)
    end
    return am.text(fn(), n.color, n.justify):tag(tag) 
end

local function getValue(n, tag, x, y, fn)
    return am.translate(x,y):tag(string.format("%s", tag))
           ^txtnd(n, tag, fn)
end

local function getValueUpdating(n, tag, x, y, fn)
    local s = string.format("%s-updatable", tag) 
    local txt = txtnd(n, s, function() return "-" end) 
    local act = function()
                 while true do
                    txt(s).text = fn()
                    coroutine.yield()
                 end
             end
    return am.translate(x,y):tag(string.format("%s", tag))
           ^txt:action(coroutine.create(act)) 
end

function Noder.Value(self)
    return function(tag, fn)
        return getValue(self, tag, 0, 0, fn)
    end
end

function Noder.UpdatingValue(self)
    return function(tag, fn)
        return getValueUpdating(self, tag, 0, 0, fn)
    end
end

function Noder.KeyValue(self)
    return function(tag, fn)
        local kt = string.format("%s-key", tag)
        local vt = string.format("%s-value", tag)
        local v = string.format("%s:", tag)
        return am.translate(0,0):tag(tag)
               ^am.group{
                    getValue(self, kt, 0, 0, function() return v end),
                    getValue(self, vt, self.hoffset, 0, fn),  
                }
    end
end

function Noder.UpdatingKeyValue(self)
    return function(tag, fn)
        local kt = string.format("%s-key", tag)
        local vt = string.format("%s-value", tag)
        local v = string.format("%s:", tag)
        return am.translate(0, 0):tag(tag)
               ^am.group{
                    getValue(self, kt, 0, 0, function() return v end),
                    getValueUpdating(self, vt, self.hoffset, 0, fn),  
                }
    end
end

function Noder:LineHeight() 
    return self.font.size
end

function Noder:Function(k)
    local action = {
        ["Value"] = self.Value,
        ["UpdatingValue"] = self.UpdatingValue, 
        ["KeyValue"] = self.KeyValue,
        ["UpdatingKeyValue"] = self.UpdatingKeyValue, 
    }
    local function act(k)
        local fn = action[k]
        return fn(self)
    end
    return act(k)
end

class("Item")

function Item:Item(tag, noder, ofk, ifn)
    self.tag = tag or "NO-ITEM-TAG"
    self.noder = noder or Noder()
    self.ofk = ofk or "Value"
    self.ifn = ifn or function() return "NOTHING" end
end

function Item:execute()
    local n = self.noder
    local ofn = n:Function(self.ofk)
    return ofn(self.tag, self.ifn)
end

class("Block")

function Block:Block(tag, button, ...)
    self.tag = tag or "BLOCK"
    self.button = button or ""
    self.has = {...}
    self.active = false
end

function Block:count()
    return table.getn(self.has)
end

function Block:height()
    local c = 0
    for _, v in ipairs(self.has) do
        c = c + v.noder:LineHeight()
    end
    return c
end

function Block:nodeGroup()
    local current = 0
    local g = am.translate(0,0)
    for _,v in ipairs(self.has) do
       g:append(am.translate(0,current)^v:execute())
       current = current - v.noder:LineHeight()
    end
    return g
end

class("Blocker")

function Blocker:Blocker(tag, origin)
    self.tag = tag or "BLOCKER"
    self.Origin = origin or {X=0,Y=0}
    self.Current = {X=0,Y=0}
    self.attached = false
    self.active = {}
end

local function base(tag, x, y)
    local bt = string.format("%s-blocks", tag)
    local ni = am.translate(x,y):tag(bt)
    return ni
end

function Blocker:root()
    self.rootNode = base(self.tag, self.Origin.X, self.Origin.Y)
    return self.rootNode
end

function Blocker:Attach(to)
    to:append(self:root())
    self.attached = true
end

function Blocker:Detach(from)
    local ni = from:remove(self.tag)
    ni = nil
    self.Current.X = 0
    self.Current.Y = 0
    self.rootNode = nil
    self.attached = false
end

function Blocker:ActiveCount()
    return table.getn(self.active)
end

function Blocker:setActive(block)
    for _,v in ipairs(self.active) do
        if v.tag == block.tag then
            return
        end
    end
    table.insert(self.active, block)
    block.active = true
end

function Blocker:Add(...)
    if self.attached and self.rootNode ~= nil then
        local nbs = {}
        local y = self.Current.Y
        for _,v in ipairs({...}) do
           local a = am.translate(0,y):tag(v.tag)
                     ^v:nodeGroup() 
           table.insert(nbs, a)
           self:setActive(v)
           y = y - v:height()
        end
        for _,v in pairs(nbs) do
            self.rootNode:append(v)
        end
        self.Current.Y = y
    end
end

local function removal(n, t) 
    for i, v in ipairs(t) do
        if n.tag == v.tag then
            n.active = false
            table.remove(t, i)
        end
    end
end

function Blocker:Remove(...)
    if self.attached and self.rootNode ~= nil then
        for _,v in ipairs({...}) do
            removal(v, self.active)
        end
        self.rootNode:remove_all()
        self.Current.X = 0
        self.Current.Y = 0
        self:Add(unpack(self.active))
    end
end

class"OSDI" ("system")

local defaultBlocks = {
        Block(
            "AM_BLOCK",
            "t",
            Item("am_version", noder, "KeyValue", function() return am.version end),
            Item("am_platform", noder,"KeyValue", function() return am.platform end),
            Item("am_language", noder, "KeyValue", function() return am.language() end)    
        ),
        --Block(
        --    "TIME_BLOCK",
        --    "",
        --    Item("os_clock", noder, "KeyValue", function() return os.clock() end),
        --    Item("os_time", noder, "KeyValue", function() return os.time() end),
        --    Item("date", noder, "KeyValue", function() return os.date() end),
        --    Item("window_time", noder, "KeyValue", function() return am.current_time() end)
        --),
        Block(
            "TIME_BLOCK_UPDATING",
            "t",
            Item("os_clock", noder, "UpdatingKeyValue", function() return os.clock() end),
            Item("os_time", noder, "UpdatingKeyValue", function() return os.time() end),
            Item("date", noder, "UpdatingKeyValue", function() return os.date() end),
            Item("window_time", noder, "UpdatingKeyValue", function() return am.current_time() end)
        ),
        --Block(
        --    "FRAME",
        --    "",
        --    Item("frame_time", noder, "KeyValue", function() return am.frame_time end), 
        --    Item("delta_time", noder, "KeyValue", function() return am.delta_time end)        
        --),
        Block(
            "FRAME_UPDATING",
            "t",
            Item("frame_time", noder, "UpdatingKeyValue", function() return am.frame_time end), 
            Item("delta_time", noder, "UpdatingKeyValue", function() return am.delta_time end)        
        ),
        --Block(
        --    "FPS",
        --    "", 
        --    Item("avg_fps", noder, "KeyValue", function() local p = am.perf_stats();return p.avg_fps end),
        --    Item("min_fps", noder, "KeyValue", function() local p = am.perf_stats();return p.min_fps end)
        --),
        Block(
            "FPS_UPDATING",
            "t",
            Item("avg_fps", noder, "UpdatingKeyValue", function() local p = am.perf_stats();return p.avg_fps end),
            Item("min_fps", noder, "UpdatingKeyValue", function() local p = am.perf_stats();return p.min_fps end)
        ),
}

function OSDI:OSDI()
    system.system(self)
    self.ui = true
    self.widgets = true
    self.noder = Noder()
    self.blocks = defaultBlocks
    self.root = am.translate(0,0):tag("on-screen-debugging-display")
end

local function blockFn(root, blocker, block)
    local function blkrAttach(root, blocker) 
        if not blocker.attached then
            blocker:Attach(root)
        end
    end
    local function blkrDetach(root, blocker)
        if blocker.attached and blocker:ActiveCount() < 1 then
            blocker:Detach(root)
        end
    end
    return function()
        blkrAttach(root, blocker)
        if not block.active then
            blocker:Add(block)
            return
        end
        if block.active then 
            blocker:Remove(block)
            blkrDetach(root, blocker)
            return
        end
    end
end

function OSDI:Init(world, broker)  
    local ev = Eventer()
    self.eventer = ev
    local events = {}
    local subscriptions = {}
    local blocker = Blocker("debugger", {X=0, Y=0}) -- Blocker("debugger", {X=w.left+10, Y=w.top-10})
    for i, v in ipairs(self.blocks) do
        table.insert(subscriptions, "KEYBOARD_PRESSED_" .. v.button)
        table.insert(events, Event(v.button, blockFn(self.root, blocker, v)))
    end

    ev:Set(events)

    broker:Subscribe(self, subscriptions)
end

function OSDI:process(dt, mouse, left, right)
    local evs = self:GetBulk()
    for k, v in pairs(evs) do
        self.eventer:Execute(v)
    end
end
