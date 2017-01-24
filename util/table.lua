--collapse a table of strings to a string
local function detable(t) 
    local ret = ""
    for _, v in ipairs(t) do
        ret = ret .. v
    end
    return ret
end

local
function table_tostring(t, indent, seen, depth)
    seen = seen or {}
    indent = indent or 0
    depth = depth or 1
    local tp = type(t)
    if tp == "table" then
        if seen[t] then
            error("cycle detected", depth + 2)
        else
            seen[t] = true
        end
        local tab = "    "
        local prefix = string.rep(tab, indent)
        local str = "{\n"
        local keys = {}
        local array_test = 1
        for key, _ in pairs(t) do
            table.insert(keys, key)
            if key ~= array_test then
                array_test = nil
            else
                array_test = array_test + 1
            end
        end
        if array_test then
            for i = 1, array_test - 1 do
                str = str .. prefix .. tab .. table_tostring(t[i], indent + 1, seen, depth + 1) .. ",\n"
            end
        else
            table.sort(keys, function(k1, k2) 
                local t1 = type(k1)
                local t2 = type(k2)
                if t1 == "string" and t2 == "string" then
                    return k1 < k2
                end
                if t1 == "number" and t2 == "number" then
                    return k1 < k2
                end
                if t1 == "string" and t2 == "number" then
                    return true
                end
                if t1 == "number" and t2 == "string" then
                    return false
                end
                return tostring(k1) < tostring(k2)
            end)
            for _, key in ipairs(keys) do
                local value = t[key]
                local keystr
                if type(key) == "string" and key:match"^[A-Za-z_][A-Za-z0-9_]*$" then
                    keystr = key
                else
                    keystr = "["..table_tostring(key, 0, seen, depth + 1).."]"
                end
                local valstr = table_tostring(value, indent + 1, seen, depth + 1)
                str = str .. prefix .. tab .. keystr .. " = " .. valstr .. ",\n"
            end
        end
        str = str .. prefix .. "}"
        return str
    elseif tp == "string" then
        return '"' .. t:gsub("\"", "\\\""):gsub("%\n", "\\n") .. '"'
    else
        return tostring(t)
    end
end

---util.table_to_string = table_tostring 

local function pprint(tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    for key, value in pairs (tt) do
      io.write(string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        io.write(string.format("[%s] => table\n", tostring (key)));
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write("(\n");
        pprint (value, indent + 7, done)
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write(")\n");
      else
        io.write(string.format("[%s] => %s\n",
            tostring (key), tostring(value)))
      end
    end
  else
    io.write(tt .. "\n")
  end
end

local function merge(t, ...)
    local m = {...}
    for _, with in ipairs(m) do
        for _, v in ipairs(with) do 
            table.insert(t,v)
        end
    end
end

return {
    merge = merge,
    pprint = pprint, 
    pstring = table_tostring,
    detable = detable,
}
