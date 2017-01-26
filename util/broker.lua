require "util.class"
require "util.buffer"
require "util.history"
local tt = require "util.table"

class("Service")

function Service:Service(tag, fn, depth)
    local function cc()
        return coroutine.create(function() if fn then return fn() end end)
    end
    local function ensure(fn)
        local co = cc()   
        return function()
            if coroutine.status(co) == 'dead' then co = cc() end
            local _, res = coroutine.resume(co)
            return res
        end
    end
    self.tag = tag
    self.info = ensure(fn)
    self.subscribers = {}
    local d = depth or 100
    self.history = History(d) 
end

class("message")

function message:message(category, from, info)
    self.category = category
    self.from = from 
    self.info = info
end

function Service:send(m)
    for _, subscriber in ipairs(self.subscribers) do
        subscriber:Message(m)
    end
    self.history:Append(Entry(m))
end

function Service:Publish()
    local info = self.info()
    local m = message("subscriber", self.tag, info)
    self:send(m)
end

function Service:Broadcast(broadcaster, message)
    local m = message("broadcast", broadcaster, message)
    self:send(m)
end

function Service:Subscribe(subscriber)
    table.insert(self.subscribers, subscriber)
end

class("Broker")

function Broker:Broker(config, game) 
    self.services = {}
    self.deferred = {}
end

function Broker:Receives(service, subscriber)
    local s = self.deferred[service]
    if s then
        table.insert(s, subscriber)
        return 
    end
    self.deferred[service] = {subscriber}
end

function Broker:Publish(service)
    table.insert(self.services, service)
    local deferred = self.deferred[service.tag]
    if deferred then
        for _, subscriber in ipairs(deferred) do
            service:Subscribe(subscriber)--self:Subscribe(service, subscriber)
        end
        --tt.pprint(deferred)
        -- deferred = {}
        -- table.remove(self.deferred, service.tag)
    end
    return function()
       service:Publish()
    end
end

function Broker:Subscribe(subscriber, services)
    for _, v in ipairs(services) do
        self:_subscribe_to(v, subscriber)   
    end
end

function Broker:_subscribe_to(service, subscriber)
    for _, v in ipairs(self.services) do
        if v.tag == service then
            v:Subscribe(subscriber)
            return
        end
    end
    self:Receives(service, subscriber)
end

function Broker:Broadcast(broadcaster, message)
    for _, service in ipairs(self.services) do
        service:Broadcast(broadcaster, message) 
    end
end

function Broker:History()
    local h = {}
    for _, v in ipairs(self.services) do
       t.merge(h, v.history:List())        
    end
    table.sort(h, function(a,b) return a.otime<b.otime end)
    table.sort(h, function(a,b) return a.gtime<b.gtime end)
    return h
end

local function initialize(game)
    return Broker()
end

return {
    Init = initialize
}
