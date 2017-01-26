require "util.class"

class"Configuration"

local function wrap(fn)
    return function(game)
        local ok, err = xpcall(function() fn(game) end, debug.traceback)
        if not ok then return err end
    end
end

function Configuration:Configuration(...)
    self.conf = {}
    for _, v in ipairs({...}) do
        local fn = wrap(v)
        table.insert(self.conf, fn)
    end
end

function Configuration:Configure(game)
    game.config = self
    for _, fn in ipairs(self.conf) do
        local res = fn(game)
        if res ~= nil then
            print(res) -- log error
            os.exit()
        end
    end
end
