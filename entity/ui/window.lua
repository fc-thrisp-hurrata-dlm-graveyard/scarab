require "util.class"
require "util.event"

class("Window")

class("Position")

function Position:Position(x, y, z)
    self.current_x = x or 0 
    self.current_y = y or 0
    self.current_z = z or 0
end

function Position:x()
    return self.current_x
end

function Position:update_x(x)
    self.current_x = x
end

function Position:y()
    return self.current_y
end

function Position:update_y(y)
    self.current_y = y
end

function Position:z()
    return self.current_z
end

function Position:update_z(z)
    self.current_z = z
end

function Position:update(x, y, z)
    self:update_x(x)
    self:update_y(y)
    self:update_z(z)
end

class("Size")

function Size:Size(w, h)
    self.current_width = w or 25 
    self.current_height = h or 25 
end

function Size:width()
    return self.current_width
end

function Size:update_width(w)
    self.current_width = w
end

function Size:height()
    return self.current_height
end

function Size:update_height(h)
    self.current_height = h
end

function Size:update(w, h)
    self:update_width(w)
    self:update_height(h)
end

class("Border")

function Border:Border(width, color, hover)
    local c = color or vec4(0, 0, 0, 0) 
    self.width = width or 1
    self.color = c 
    self.default = c
    self.hover = hover or c
end

function Border:Color()
    return self.color
end

function Border:onEnter()
    self.color = self.hover
end

function Border:onExit()
    self.color = self.default
end

class("Background")

function Background:Background(color, hover)
    local c = color or vec4(0, 0, 0, 0) 
    self.color = c
    self.default = c 
    self.hover = hover or c 
end

function Background:Color()
    return self.color
end

function Background:onEnter()
    self.color = self.hover
end

function Background:onExit()
    self.color = self.default
end

local function updatingLine(tag, startFn, stopFn, wFn, cFn)
    local line = am.line(startFn(), stopFn(), wFn(), cFn())--:tag(tag) 

    local act = function()
                    while true do
                        line.point1 = startFn()
                        line.point2 = stopFn()
                        line.thickness = wFn()
                        line.color  = cFn()
                        coroutine.yield()
                    end
                end

    return line:action(coroutine.create(act))
end

local function updatingRect(tag, vFn, bcFn)
    local a, b = vFn() 
    local r = am.rect(a.x, a.y, b.x, b.y, bcFn())--:tag(tag)
    local act = function()
                    while true do
                        local aa, bb = vFn()
                        r.x1 = aa.x
                        r.y1 = aa.y
                        r.x2 = bb.x
                        r.y2 = bb.y
                        r.color = bcFn()
                        coroutine.yield()
                    end
                end
    return r:action(coroutine.create(act))
end

local function window_root(w)
    local function ntag(s)
        return w.tag .. s
    end

    local size, position, border, background = w.size, w.position, w.border, w.background
    
    local tl = function() return w:TL() end 
    local tr = function() return w:TR() end 
    local br = function() return w:BR() end 
    local bl = function() return w:BL() end

    local bwFn = function() return border.width end
    local bcFn = function() return border:Color() end

    local function frame(w) 
        local top = updatingLine(ntag("-TOP"), tl, tr, bwFn, bcFn)
        local right = updatingLine(ntag("-RIGHT"), tr, br, bwFn, bcFn)
        local bottom = updatingLine(ntag("-BOTTOM"), br, bl, bwFn, bcFn) 
        local left = updatingLine(ntag("-LEFT"), bl, tl, bwFn, bcFn)
        return am.translate(0,0):tag(ntag("-BORDER"))
               ^am.group{
                    top,
                    right,
                    bottom,
                    left
                }
    end

    local areaFn = function() return w:TL(), w:BR() end

    local bkcFn = function() return background.color end 

    local function area(w)
        return updatingRect(ntag("-WINDOW-AREA"), areaFn, bkcFn) 
    end

    local a = area(w)

    local f = frame(w)

    local base = am.group{
            a,
            f
        } 

    local n = am.translate(0,0):tag(ntag("-WINDOW"))
              ^base

    return n
end

local function wrap(window, fns)
    return function()
        for _, v in ipairs(fns) do
            v(window)  
        end
    end
end

function Window:Window(tag, position, size, border, background, onEnter, onExit, leftClick, rightClick)
    self.tag = tag or "WINDOW" 
    self.ui = true
    self.window = true
    self.position = position 
    self.size = size
    self.border = border
    self.background = background
    self.eventer = Eventer(
                    nil, 
                    Event("onEnter", wrap(self, onEnter)),
                    Event("onExit", wrap(self, onExit)),
                    Event("leftClick", wrap(self, leftClick)),
                    Event("rightClick", wrap(self, rightClick))
                   ) 
    self.root = window_root(self)
    self.hover = false
end

function Window:TL()
    return vec2(
        self.position:x(),
        self.position:y()
    )
end

function Window:TR()
    return vec2(
        self.position:x() + self.size:width(),
        self.position:y()
    )
end

function Window:BR()
    return vec2(
        self.position:x() + self.size:width(),
        self.position:y() - self.size:height()
    )
end

function Window:BL()
    return vec2(
        self.position:x(),
        self.position:y() - self.size:height()
    )
end

function Window:C()
    return vec2(
        self.position:x() + (self.size:width() / 2),
        self.position:y() + (self.size:height() / 2)
    )
end

function Window:Position(v)
    self.position:update(v.x, v.y)
end

function Window:Width(w)
    self.size:update_width(w)
end

function Window:Height(h)
    self.size:update_height(h)
end

function Window:Size(w, h)
    self:Width(w)
    self:Height(h)
end

function Window:IsInside(point)
    local v1, v2 = self:TL(), self:BR()
    if v1.x <= point.x 
        and point.x <= v2.x
        and v1.y >= point.y
        and point.y >= v2.y then
        return true
    end
    return false
end

function Window:process(dt, hover, lc, rc)
    local e = self.eventer

    if hover and not self.hover then
        self.hover = true
        e:Execute("onEnter")
    end

    if self.hover and not hover then
        self.hover = false
        e:Execute("onExit")
    end

    if self.hover and lc then
        e:Execute("leftClick")
    end

    if self.hover and rc then
        e:Execute("rightClick")
    end
end
