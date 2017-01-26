local tt = require "util.table"

local function item(k,v)
    return {
        key = k,
        value = v,
    } 
end

local settings = {
    has = {},
}

local function get(k)
    local i = settings.has[k]
    if i ~= nil then
        return i.value
    end
end

local function set(k,v)
    local i = item(k,v) 
    settings.has[k] = i
end

set("testing", true)
set("widget_limit", 5000)

return { 
    Get = get,
    Set = set,
}
