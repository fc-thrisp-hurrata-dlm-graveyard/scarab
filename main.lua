require "game"

function loadConfig(path)
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
end

function main(path)
    local config = loadConfig(path)
    local game = Game(config)
    game:Start()
end

noglobals()
main("config.lua")
