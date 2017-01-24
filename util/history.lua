require "util.buffer"
require "util.class"

class"History"

local function b(i)
    if i > 0 then 
        return cuffer(i)
    end
    return iuffer() 
end

function History:History(depth)
    local d = depth or 0
    self.buffer = b(d)
end

function History:Append(e)
    self.buffer:_append(e)
end

function History:List()
    return self.buffer:list()
end

class"Entry"

function Entry:Entry(message)
    self.otime = os.time()
    self.gtime = am.current_time()
    self.message = message
end
