if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G

if env.TigrimExtraStop then pcall(env.TigrimExtraStop) end
local alive = true
local conns = {}
local function keep(c) table.insert(conns, c) return c end

local RANGE = 300
local FILE = "TigrimExtra.json"
local defaults = {snd = true, glow = true, destroy = true, anim = true, aura = true, fpscap = true}
local S = env.TigrimExtraS or {}
env.TigrimExtraS = S
for k, v in pairs(defaults) do S[k] = v end
pcall(function()
	if isfile and isfile(FILE) then
		local d = HttpService:JSONDecode(readfile(FILE))
		for k, v in pairs(d) do
			if defaults[k] ~= nil and type(v) == "boolean" then S[k] = v end
		end
	end
end)
local function save()
	pcall(function() if writefile then writefile(FILE, HttpService:JSONEncode(S)) end end)
end

local okG, guiParent = pcall(function() return (gethui and gethui()) or game:GetService("CoreGui") end)
if not okG or not guiParent then guiParent = lp:WaitForChild("PlayerGui") end
pcall(function()
	local o = guiParent:FindFirstChild("TigrimExtra")
	if o then o:Destroy() end
end)

---------------------------------------------------------------- SONS
env.TigrimExtraVol = env.TigrimExtraVol or setmetatable({}, {__mode = "k"})
local origVol = env.TigrimExtraVol
local sndConn = {}
local CoreGui = game:GetService("CoreGui")

local function muteSound(s)
	if s:IsDescendantOf(lp.PlayerGui) or s:IsDescendantOf(CoreGui) then return end
	if s.Volume > 0 then origVol[s] = s.Volume end
	s.Volume = 0
	if not sndConn[s] then
		sndConn[s] = s:GetPropertyChangedSignal("Volume"):Connect(function()
			if S.snd and alive and s.Volume > 0 then
				origVol[s] = s.Volume
				s.Volume = 0
			end
		end)
	end
end
local function unmuteAll()
	for s, c in pairs(sndConn) do c:Disconnect() end
	sndConn = {}
	for s, v in pairs(origVol) do
		pcall(function() s.Volume = v end)
		origVol[s] = nil
	end
end

---------------------------------------------------------------- BRILHO / DESTRUIÇÃO
local cat = {glow = {en = {}, hid = {}}, dest = {en = {}, hid = {}}}
local EFFECT_FOLDERS = {_WorldOrigin = true, Effects = true, Debris = true}

local function disable(c, o, prop)
	if c.en[o] == nil then c.en[o] = o[prop] end
	o[prop] = false
end
local function hide(c, o)
	c.hid[o] = true
	o.LocalTransparencyModifier = 1
end
local function restore(c)
	for o, v in pairs(c.en) do
		pcall(function()
			if o:IsA("Explosion") then o.Visible = v else o.Enabled = v end
		end)
	end
	for o in pairs(c.hid) do pcall(function() o.LocalTransparencyModifier = 0 end) end
	c.en, c.hid = {}, {}
end

local function inCharacter(o)
	local m = o:FindFirstAncestorOfClass("Model")
	while m do
		if Players:GetPlayerFromCharacter(m) or m:FindFirstChildOfClass("Humanoid") then return true end
		m = m.Parent and m.Parent:FindFirstAncestorOfClass("Model")
	end
	return false
end

local function inEffectFolder(o)
	local top = o
	while top.Parent and top.Parent ~= workspace do top = top.Parent end
	return top.Parent == workspace and EFFECT_FOLDERS[top.Name] == true
end

local function handle(o)
	if S.snd and o:IsA("Sound") then muteSound(o) return end
	if S.glow then
		if o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight") or o:IsA("Highlight") then
			if o.Name ~= "TigrimAura" then disable(cat.glow, o, "Enabled") end
		elseif o:IsA("PostEffect") then
			disable(cat.glow, o, "Enabled")
		elseif o:IsA("BasePart") and (o.Material == Enum.Material.Neon or o.Material == Enum.Material.ForceField)
			and not o.CanCollide and not inCharacter(o) then
			hide(cat.glow, o)
		end
	end
	if S.destroy then
		if o:IsA("Explosion") then
			disable(cat.dest, o, "Visible")
		elseif o:IsA("BasePart") or o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam")
			or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then
			if inEffectFolder(o) then
				if o:IsA("BasePart") then hide(cat.dest, o) else disable(cat.dest, o, "Enabled") end
			end
		end
	end
end

local function sweep()
	local n = 0
	for _, r in ipairs({workspace, Lighting, SoundService}) do
		for _, o in ipairs(r:GetDescendants()) do
			pcall(handle, o)
			n += 1
			if n % 500 == 0 then task.wait() end
		end
	end
end

for _, r in ipairs({workspace, Lighting, SoundService}) do
	keep(r.DescendantAdded:Connect(function(o)
		pcall(handle, o)
		if o:IsA("BasePart") then task.defer(pcall, handle, o) end
	end))
end

---------------------------------------------------------------- HOOK (menu sem animação + sons)
local hooked = false
if hookmetamethod and getnamecallmethod then
	hooked = true
	if not env.TigrimExtraHooked then
		env.TigrimExtraHooked = true
		local wrap = newcclosure or function(f) return f end
		local PG = lp:WaitForChild("PlayerGui")
		local old
		old = hookmetamethod(game, "__namecall", wrap(function(self, ...)
			local m = getnamecallmethod()
			local A = env.TigrimExtraS
			if A and not (checkcaller and checkcaller()) then
				if A.anim then
					if m == "Create" and self == TweenService then
						local inst, info, goal = ...
						if typeof(inst) == "Instance" and typeof(info) == "TweenInfo" and type(goal) == "table"
							and pcall(function() return inst.AbsoluteSize end) then
							for k, v in pairs(goal) do pcall(function() inst[k] = v end) end
							return old(self, inst, TweenInfo.new(0), goal)
						end
					elseif m == "TweenPosition" or m == "TweenSize" or m == "TweenSizeAndPosition" then
						if pcall(function() return self.AbsoluteSize end) then
							local a, b, c, d, e, f, g = ...
							local cb
							if m == "TweenPosition" then self.Position = a; cb = f
							elseif m == "TweenSize" then self.Size = a; cb = f
							else self.Size = a; self.Position = b; cb = g end
							if type(cb) == "function" then task.spawn(cb, Enum.TweenStatus.Completed) end
							return true
						end
					end
				end
				if A.snd and m == "Play" then
					pcall(function()
						if self.ClassName == "Sound" then
							local p, ui = self, false
							while p and p ~= game do
								if p == PG or p == CoreGui then ui = true break end
								p = p.Parent
							end
							if not ui then
								if self.Volume > 0 then env.TigrimExtraVol[self] = self.Volume end
								self.Volume = 0
							end
						end
					end)
				end
			end
			return old(self, ...)
		end))
	end
end

---------------------------------------------------------------- AURA VERDE
local auraFolder = Instance.new("Folder")
auraFolder.Name = "TigrimAuraFolder"
if not pcall(function() auraFolder.Parent = guiParent end) then auraFolder.Parent = workspace end
local auras = {}

local function removeAura(p)
	local h = auras[p]
	if h then h:Destroy() end
	auras[p] = nil
end

local function auraStep()
	local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp then
			local ch = p.Character
			local r = ch and ch:FindFirstChild("HumanoidRootPart")
			if S.aura and myRoot and r and (r.Position - myRoot.Position).Magnitude <= RANGE then
				local h = auras[p]
				if not h or h.Adornee ~= ch then
					if h then h:Destroy() end
					h = Instance.new("Highlight")
					h.Name = "TigrimAura"
					h.FillColor = Color3.fromRGB(0, 255, 60)
					h.FillTransparency = 0.55
					h.OutlineColor = Color3.fromRGB(0, 255, 60)
					h.OutlineTransparency = 0
					h.DepthMode = Enum.HighlightDepthMode.Occluded
					h.Adornee = ch
					h.Parent = auraFolder
					auras[p] = h
				end
			else
				removeAura(p)
			end
		end
	end
	for p in pairs(auras) do
		if not p.Parent then removeAura(p) end
	end
end

task.spawn(function()
	local n = 0
	while alive do
		pcall(auraStep)
		n += 1
		if n % 20 == 0 then
			for s, c in pairs(sndConn) do
				if not s.Parent then c:Disconnect(); sndConn[s] = nil; origVol[s] = nil end
			end
			for _, c in pairs(cat) do
				for o in pairs(c.en) do if not o.Parent then c.en[o] = nil end end
				for o in pairs(c.hid) do if not o.Parent then c.hid[o] = nil end end
			end
		end
		task.wait(0.25)
	end
end)

---------------------------------------------------------------- FPS
local function applyFps()
	if setfpscap then pcall(setfpscap, S.fpscap and 999 or 60) end
end

---------------------------------------------------------------- PAINEL
local gui = Instance.new("ScreenGui")
gui.Name = "TigrimExtra"
gui.ResetOnSpawn = false
gui.DisplayOrder = 998
gui.Parent = guiParent

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 230, 0, 0)
main.AutomaticSize = Enum.AutomaticSize.Y
main.Position = UDim2.new(1, -240, 0, 70)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
local pad = Instance.new("UIPadding", main)
pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 6), UDim.new(0, 6)
pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 6), UDim.new(0, 6)
local lay = Instance.new("UIListLayout", main)
lay.Padding = UDim.new(0, 5)
lay.SortOrder = Enum.SortOrder.LayoutOrder

local titleRow = Instance.new("Frame")
titleRow.LayoutOrder = 0
titleRow.Size = UDim2.new(1, 0, 0, 26)
titleRow.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
titleRow.BorderSizePixel = 0
titleRow.Parent = main
Instance.new("UICorner", titleRow).CornerRadius = UDim.new(0, 6)

local tl = Instance.new("TextLabel")
tl.Size = UDim2.new(1, -40, 1, 0)
tl.Position = UDim2.new(0, 8, 0, 0)
tl.BackgroundTransparency = 1
tl.Text = "TIGRIM021 • Extra"
tl.TextColor3 = Color3.fromRGB(255, 200, 60)
tl.Font = Enum.Font.GothamBold
tl.TextSize = 13
tl.TextXAlignment = Enum.TextXAlignment.Left
tl.Parent = titleRow

local colBtn = Instance.new("TextButton")
colBtn.Size = UDim2.new(0, 26, 0, 20)
colBtn.Position = UDim2.new(1, -30, 0, 3)
colBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
colBtn.Text = "-"
colBtn.TextColor3 = Color3.new(1, 1, 1)
colBtn.Font = Enum.Font.GothamBold
colBtn.TextSize = 16
colBtn.Parent = titleRow
Instance.new("UICorner", colBtn).CornerRadius = UDim.new(0, 6)

do
	local dragging, startPos, startFramePos
	titleRow.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startPos, startFramePos = i.Position, main.Position
		end
	end)
	keep(UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - startPos
			main.Position = UDim2.new(startFramePos.X.Scale, startFramePos.X.Offset + d.X,
				startFramePos.Y.Scale, startFramePos.Y.Offset + d.Y)
		end
	end))
	keep(UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))
end

local onChange = {
	snd = function(v) if v then sweep() else unmuteAll() end end,
	glow = function(v) if v then sweep() else restore(cat.glow) end end,
	destroy = function(v) if v then sweep() else restore(cat.dest) end end,
	anim = function() end,
	aura = function(v) if not v then for p in pairs(auras) do removeAura(p) end end end,
	fpscap = function() applyFps() end,
}

local TOGGLES = {
	{"Sem sons de ataque/skill", "snd"},
	{"Sem brilho", "glow"},
	{"Sem efeitos de destruição", "destroy"},
	{"Menu sem animação", "anim"},
	{"Aura verde (300)", "aura"},
	{"FPS sem limite", "fpscap"},
}
local btns = {}
for i, t in ipairs(TOGGLES) do
	local b = Instance.new("TextButton")
	b.LayoutOrder = i
	b.Size = UDim2.new(1, 0, 0, 32)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.Parent = main
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	local function refresh()
		b.Text = t[1] .. ":  " .. (S[t[2]] and "ON" or "OFF")
		b.BackgroundColor3 = S[t[2]] and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(45, 45, 55)
	end
	b.Activated:Connect(function()
		S[t[2]] = not S[t[2]]
		refresh()
		task.spawn(function() pcall(onChange[t[2]], S[t[2]]) end)
		save()
	end)
	refresh()
	btns[i] = b
end

local collapsed = false
colBtn.Activated:Connect(function()
	collapsed = not collapsed
	for _, b in ipairs(btns) do b.Visible = not collapsed end
	colBtn.Text = collapsed and "+" or "-"
end)

---------------------------------------------------------------- INICIAR
env.TigrimExtraStop = function()
	alive = false
	for _, c in ipairs(conns) do c:Disconnect() end
	unmuteAll()
	restore(cat.glow)
	restore(cat.dest)
	for p in pairs(auras) do removeAura(p) end
	gui:Destroy()
	auraFolder:Destroy()
end

applyFps()
task.spawn(sweep)
if not hooked then
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Tigrim Extra",
			Text = "Seu executor não tem hookmetamethod: menu sem animação e parte dos sons podem não funcionar.",
			Duration = 8,
		})
	end)
end
print("[Tigrim Extra] carregado")
