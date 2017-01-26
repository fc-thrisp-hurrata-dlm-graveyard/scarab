require "util.class"
require "util.buffer"
local t = require "util.table"

class("Input")

function Input:Input(tag, action, eventer)
    self.game = true
    self.input = true
    self.tag = tag
    self.action = action
    self.eventer = eventer
end

local function attach(scene, fn)
    scene:action(
        fn,
        coroutine.create(
            function()
                while true do
                    fn:Execute()
                    coroutine.yield()
                end
            end)
    )
end

function Input:Attach(scene)
    attach(scene, self)
end

local function detach(scene, fn)
    scene:cancel(fn)
end

function Input:Detach(scene)
    detach(scene, self)
end

function Input:Execute()
    local action = self.action()

    local eventer = self.eventer

    eventer:Execute(action)
end

class("Inputer")

function Inputer:Inputer(tag, ...)
    self.game = true
    self.input = true
    self.tag = tag
    self.has = {...}
end

function Inputer:Attach(scene)
    local inputs = self.has

    for _, fn in ipairs(inputs) do
        attach(scene, fn)
    end
end

function Inputer:Detach(scene)
    local inputs = self.has

    for _, fn in ipairs(inputs) do
        detach(scene, fn)
    end
end

local function keyboardService(tag)
    return Service("KEYBOARD_PRESSED_" .. tag, function() return tag end)
end

local function keyboardDefaults(window, broker)
    return {
        Input(
            "keyboard.default.pressed",
            function() return window:keys_pressed() end,
            Eventer(
                chain(1),
                Event(
                    "h",
                    function() t.pprint(broker:History()) end,
                    broker:Publish(keyboardService("h"))
                ),
                Event(
                    "q",
                    function() print("EJECT!EJECT!") end,
                    function() print("hard exit..."); os.exit() end,
                    broker:Publish(keyboardService("q")) 
                ),
                Event(
                    "t",
                    function() print(am.current_time()) end,
                    broker:Publish(keyboardService("t"))
                ),
                Event(
                    "99",
                    function() print("!99") end,
                    broker:Publish(keyboardService("99"))
                ) 
            )
        ) 
    }
end

local function mouseDefaults(window, broker)
    return {
        Input(
            "mouse.default.position",
             function() end,
             Eventer(
                auffer("mouse-position"),
                Event(
                    "mouse-position",
                    broker:Publish(
                        Service(
                            "MOUSE_POSITION",
                            function() return window:mouse_position() end
                        )
                    )
                )     
             )
        ),
        Input(
            "mouse.default.left.click",
             function() end,
             Eventer(
                auffer("mouse-left-click"),
                Event(
                    "mouse-left-click",
                    broker:Publish(
                        Service(
                            "MOUSE_LEFT_CLICK",
                            function() return window:mouse_pressed("left") end
                        )
                    )
                  )         
             )
        ),
        Input(
             "mouse.default.right.click",
             function() end,
             Eventer(
                auffer("mouse-right-click"),
                Event(
                    "mouse-right-click",
                    broker:Publish(
                        Service(
                            "MOUSE_RIGHT_CLICK",
                            function() return window:mouse_pressed("right") end
                        )    
                    )
                )
             )
        ),
    }
end

local function init(game)
    local window = game.window
    local broker = game.broker

    local i = {}

    local k = keyboardDefaults(window, broker)

    local m = mouseDefaults(window, broker)

    t.merge(i, k, m)

    local di = Inputer("inputer.default", unpack(i))
    
    local scene = window.scene

    di:Attach(scene)

    return di
end

return {
    Init = init,
}
