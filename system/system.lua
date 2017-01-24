require "util.class"

class("system")

function system:system()
    self.messages = {}
end

function system:Message(message)
    self.messages[message.from] = message
end

function system:GetMessageInfo(tag)
    local m = self.messages[tag]
    if m ~= nil then
        self.messages[tag] = nil
        return m.info
    end
end

function system:GetBulkTags()
    local ret = {}
    for k, _ in pairs(self.messages) do
        table.insert(ret, k)
    end
    return ret
end

function system:GetBulk()
    local ret = {}
    local tags = self:GetBulkTags()
    for _, v in ipairs(tags) do
        ret[v] = self:GetMessageInfo(v)
    end
    return ret
end
