require "game"
local settings = require "settings"

--[[function load(path)
    local f, e = loadfile(path)
    if f == nil then
        print(e) -- handle error; e has the error message
        os.exit()
    end
    local ok, e = pcall(f)
    if not ok then
        print(e) -- handle error; e has the error message
        os.exit()
    end

    return f()
end]]

function main(s)
    --local settings = load(settings)
    local game = Game(s)
    game:Enter()
end

noglobals()
main(settings)
