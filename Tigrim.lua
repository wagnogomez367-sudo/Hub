local base = "https://raw.githubusercontent.com/wagnogomez367-sudo/Hub/main/"
local env = (getgenv and getgenv()) or _G
loadstring(game:HttpGet(base .. "Load.lua"))()
loadstring(game:HttpGet(base .. "hub.lua"))()
local t0 = os.clock()
repeat task.wait(0.5) until env.TigrimLoadDone or os.clock() - t0 > 45
loadstring(game:HttpGet(base .. "Extra.lua"))()
