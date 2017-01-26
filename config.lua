require "util.configuration"
local b = require "util.broker"
require "util.ecs"
local gw = require "system.game.window"
local gi = require "system.game.input"
local ie = require "entity.game.input"
local ui = require "system.ui.ui"
local ce = require "entity.ui.cursor"
require "entity.ui.osdi"
require "entity.ui.windows"
require "entity.ui.window"

local function configureSystem(s)
    return function(g)
        local wd = g.world
        s:Init(g)
        wd:addSystem(s)
    end
end

local function addEntity(fn)
    return function(g)
        local wd = g.world
        local entity = fn(g)
        wd:addEntity(entity)
    end
end

local configuration = Configuration(
    function(g)
        g.window = am.window{    
            title = "scarab: a skeleton, toy, and test framework for the Amulet game framework",
            letterbox = false,
            clear_color = vec4(0.01, 0.01, 0.01, 1),
            show_cursor = false,
        } 
    end,
    function(g)
        g.broker = b.Init(g)
    end,
    function(g)
        g.world = ecs.world() 
    end,
    configureSystem(gw),                          -- game window system
    configureSystem(gi),                          -- game input system
    configureSystem(ui),                          -- ui system
    addEntity(ie.Init),                           -- add some input defaults
    addEntity(ce.Init),                           -- cursor 
    function(g)                                   -- test some widgets
        if g("testing") then
            local world = g.world
   
            local widgets = Windows()

            world:addEntity(widgets)

            math.randomseed(os.time())

            local function widget(tag)
                return Window(
                    tag,
                    Position(math.random(-500, 500), math.random(-400, 400)),
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
            end
            
            local wl = g("widget_limit")
            for i = 1,wl do
                local nw = widget("W-".. i)        
                world:addEntity(nw)
                widgets.stack:push(nw)
            end
        end
    end,
    function(g)                                  -- on screen information display                                 
        if g("testing") then
            local world = g.world
            world:addEntity(OSDI())                               
        end
    end
) 

return configuration
