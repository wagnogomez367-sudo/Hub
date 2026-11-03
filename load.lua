if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G

if env.TigrimLoad and env.TigrimLoad.close then pcall(env.TigrimLoad.close) end
env.TigrimLoadDone = false

local ok, parent = pcall(function() return (gethui and gethui()) or game:GetService("CoreGui") end)
if not ok or not parent then parent = lp:WaitForChild("PlayerGui") end
pcall(function()
	local o = parent:FindFirstChild("TigrimLoad")
	if o then o:Destroy() end
end)

local ORANGE = Color3.fromRGB(255, 130, 20)
local DARK = Color3.fromRGB(45, 30, 20)
local EMBER = {Color3.fromRGB(255, 140, 30), Color3.fromRGB(255, 200, 60), Color3.fromRGB(255, 80, 20)}

local gui = Instance.new("ScreenGui")
gui.Name = "TigrimLoad"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 10000
gui.Parent = parent

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BorderSizePixel = 0
bg.Active = true
bg.Parent = gui

local center = Instance.new("Frame")
center.Size = UDim2.new(0, 220, 0, 220)
center.AnchorPoint = Vector2.new(0.5, 0.5)
center.Position = UDim2.new(0.5, 0, 0.5, 0)
center.BackgroundTransparency = 1
center.Parent = bg

local N = 60
local segs = {}
for i = 1, N do
	local a = (i - 1) / N * math.pi * 2 - math.pi / 2
	local s = Instance.new("Frame")
	s.Size = UDim2.new(0, 4, 0, 14)
	s.AnchorPoint = Vector2.new(0.5, 0.5)
	s.Position = UDim2.new(0.5, math.cos(a) * 95, 0.5, math.sin(a) * 95)
	s.Rotation = math.deg(a) + 90
	s.BackgroundColor3 = DARK
	s.BorderSizePixel = 0
	s.Parent = center
	segs[i] = s
end

local orb = Instance.new("Frame")
orb.Size = UDim2.new(0, 96, 0, 96)
orb.AnchorPoint = Vector2.new(0.5, 0.5)
orb.Position = UDim2.new(0.5, 0, 0.5, 0)
orb.BackgroundColor3 = Color3.new(1, 1, 1)
orb.BorderSizePixel = 0
orb.Parent = center
Instance.new("UICorner", orb).CornerRadius = UDim.new(1, 0)
local g = Instance.new("UIGradient", orb)
g.Color = ColorSequence.new(Color3.fromRGB(255, 220, 90), Color3.fromRGB(230, 60, 10))
g.Rotation = 90
local st = Instance.new("UIStroke", orb)
st.Color = ORANGE
st.Thickness = 3

local function label(y, size, font, color)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0, 260, 0, size + 6)
	l.AnchorPoint = Vector2.new(0.5, 0.5)
	l.Position = UDim2.new(0.5, 0, 0.5, y)
	l.BackgroundTransparency = 1
	l.TextColor3 = color
	l.Font = font
	l.TextSize = size
	l.Parent = center
	return l
end
local pct = label(145, 28, Enum.Font.GothamBold, Color3.new(1, 1, 1))
pct.Text = "0%"
local status = label(178, 13, Enum.Font.Gotham, Color3.fromRGB(255, 190, 90))
status.Text = "Iniciando..."

local target, shown, lit, t, acc = 0, 0, 0, 0, 0
local embers = {}
local closed = false
local conn

conn = RunService.Heartbeat:Connect(function(dt)
	shown = math.min(target, shown + dt * 0.8)
	local n = math.floor(shown * N + 0.5)
	if n ~= lit then
		lit = n
		for i, s in ipairs(segs) do s.BackgroundColor3 = (i <= n) and ORANGE or DARK end
	end
	pct.Text = math.floor(shown * 100 + 0.5) .. "%"

	t += dt
	local sz = 96 + math.sin(t * 4.5) * 7
	orb.Size = UDim2.new(0, sz, 0, sz)

	acc += dt
	if acc >= 0.1 then
		acc = 0
		for _ = 1, 2 do
			local s = math.random(3, 7)
			local f = Instance.new("Frame")
			f.Size = UDim2.new(0, s, 0, s)
			f.AnchorPoint = Vector2.new(0.5, 0.5)
			f.BackgroundColor3 = EMBER[math.random(1, #EMBER)]
			f.BorderSizePixel = 0
			Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
			f.Parent = bg
			table.insert(embers, {f = f, age = 0, life = math.random(18, 30) / 10,
				x = math.random(-110, 110), dx = math.random(-40, 40),
				y0 = math.random(60, 140), rise = math.random(240, 460)})
		end
	end
	for i = #embers, 1, -1 do
		local e = embers[i]
		e.age += dt
		local k = e.age / e.life
		if k >= 1 then
			e.f:Destroy()
			table.remove(embers, i)
		else
			e.f.Position = UDim2.new(0.5, e.x + e.dx * k, 0.5, e.y0 - e.rise * k)
			e.f.BackgroundTransparency = k
		end
	end
end)

local function close()
	if closed then return end
	closed = true
	conn:Disconnect()
	gui:Destroy()
	env.TigrimLoadDone = true
end

env.TigrimLoad = {
	step = function(p, text)
		target = p
		if text then status.Text = text end
	end,
	finish = function()
		target = 1
		status.Text = "Pronto!"
		local t0 = os.clock()
		while shown < 0.999 and os.clock() - t0 < 6 do task.wait() end
		task.wait(0.3)
		close()
	end,
	close = close,
}

task.delay(45, close)
