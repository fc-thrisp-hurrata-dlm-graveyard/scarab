require "util.class"
local c = require "config"

class("Game")

function Game:Game(settings)
    self.settings = settings
    c:Configure(self)
end

function Game:__call(s)
    return self.settings.Get(s)
end

function Game:Enter()
end

function Game:Exit()
    os.exit()
end
