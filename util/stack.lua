require "util.class"

class("stack")

function stack:stack()
    self._entries = {}
end

function stack:list()
    return self._entries
end

function stack:push(...)
    if ... then
        local items = {...}
        for _, v in ipairs(items) do
            table.insert(self._entries, v)
        end
    end 
end

function stack:pop(idx)
    local idx = idx or 1
    local ret = table.remove(self._entries, idx)
    return ret
end
