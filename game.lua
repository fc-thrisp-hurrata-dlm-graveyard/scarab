require "util.class"
local b = require "util.broker"
local w = require "util.world"

class("Game")

function Game:Game(config)
    self.config = config
    self.broker = b.Init(self)
    self.world  = w.Init(self)
end

function Game:Start()
end

function Game:Exit()
    os.exit()
end
