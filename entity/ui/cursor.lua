require "util.class"

class("Cursor")

local arrow = [[
WWWWWWWWW.....
WWWWWWWWW.....
WWWW..........
WWWW..........
WW..WW........
WW..WW........
WW....WW......
WW....WW......
WW......WW....
........WW....
..........WW..
..........WW..
............WW
............WW
]]

local wait = [[
WWWWWWWWWWWWWW
WWWWWWWWWWWWWW
..WW......WW..
..WW......WW..
....WW..WW....
....WW..WW....
......WW......
......WW......
....WW..WW....
....WW..WW....
..WW......WW..
..WW......WW..
WWWWWWWWWWWWWW
WWWWWWWWWWWWWW
]]

local function cursorNode()
    local sp = am.sprite(arrow, vec4(1,0,1,1), "left", "top") 

    local inner = am.translate(0,0)
                  ^sp

    local wrapped = am.wrap(inner)

    function wrapped:position(p)
        inner.position2d = p
    end

    function wrapped:wait()
        sp.source = wait 
    end

    return wrapped
end

function Cursor:Cursor()
    self.ui = true
    self.cursor = true
    self.root = cursorNode()
end

function Cursor:update(position)
    if position ~= nil then
        local r = self.root
        r:position(position)
    end
end

local function init(game)
    return Cursor()
end

return {
    Init = init,
}
