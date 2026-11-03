local SG = game:GetService("StarterGui")
local function notify(t)
	pcall(function()
		SG:SetCore("SendNotification", {Title = "Tigrim", Text = tostring(t):sub(1, 150), Duration = 8})
	end)
end
notify("Script iniciado...")

local ok, err = pcall(function()
if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local CoreGui = game:GetService("CoreGui")
local Terrain = workspace.Terrain
local lp = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G

if env.TigrimStop then pcall(env.TigrimStop) end
local alive = true
local conns = {}
local function keep(c) conns[#conns + 1] = c return c end

---------------------------------------------------------------- CONFIG
local FILE = "TigrimHub_config.json"
local defaults = {
	boost = true, names = true, chat = true, fps = false, stretch = false, stretchVal = 0.7,
	snd = true, glow = true, destroy = true, anim = true, aura = true, fpscap = true,
}
local S = {}
for k, v in pairs(defaults) do S[k] = v end
env.TigrimS = S
pcall(function()
	if isfile and isfile(FILE) then
		local d = HttpService:JSONDecode(readfile(FILE))
		for k, v in pairs(d) do
			if defaults[k] ~= nil and type(v) == type(defaults[k]) then S[k] = v end
		end
	end
end)
local function save()
	pcall(function() if writefile then writefile(FILE, HttpService:JSONEncode(S)) end end)
end

local okG, guiParent = pcall(function() return (gethui and gethui()) or CoreGui end)
if not okG or not guiParent then guiParent = lp:WaitForChild("PlayerGui") end
pcall(function()
	for _, n in ipairs({"TigrimHub", "TigrimLoad"}) do
		local o = guiParent:FindFirstChild(n)
		if o then o:Destroy() end
	end
end)

---------------------------------------------------------------- LOADING
local ORANGE = Color3.fromRGB(255, 130, 20)
local DARK = Color3.fromRGB(45, 30, 20)
local EMBER = {Color3.fromRGB(255, 140, 30), Color3.fromRGB(255, 200, 60), Color3.fromRGB(255, 80, 20)}

local lg = Instance.new("ScreenGui")
lg.Name = "TigrimLoad"
lg.ResetOnSpawn = false
lg.IgnoreGuiInset = true
lg.DisplayOrder = 10000
lg.Parent = guiParent

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BorderSizePixel = 0
bg.Active = true
bg.Parent = lg

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
local og = Instance.new("UIGradient", orb)
og.Color = ColorSequence.new(Color3.fromRGB(255, 220, 90), Color3.fromRGB(230, 60, 10))
og.Rotation = 90
local ost = Instance.new("UIStroke", orb)
ost.Color = ORANGE
ost.Thickness = 3

local function mkLabel(y, size, font, color)
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
local pct = mkLabel(145, 28, Enum.Font.GothamBold, Color3.new(1, 1, 1))
pct.Text = "0%"
local status = mkLabel(178, 13, Enum.Font.Gotham, Color3.fromRGB(255, 190, 90))
status.Text = "Iniciando..."

local target, shown, lit, tm, acc = 0, 0, 0, 0, 0
local embers = {}
local loadClosed = false
local loadConn

loadConn = RunService.Heartbeat:Connect(function(dt)
	shown = math.min(target, shown + dt * 0.8)
	local n = math.floor(shown * N + 0.5)
	if n ~= lit then
		lit = n
		for i, s in ipairs(segs) do s.BackgroundColor3 = (i <= n) and ORANGE or DARK end
	end
	pct.Text = math.floor(shown * 100 + 0.5) .. "%"
	tm = tm + dt
	local sz = 96 + math.sin(tm * 4.5) * 7
	orb.Size = UDim2.new(0, sz, 0, sz)
	acc = acc + dt
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
			embers[#embers + 1] = {f = f, age = 0, life = math.random(18, 30) / 10,
				x = math.random(-110, 110), dx = math.random(-40, 40),
				y0 = math.random(60, 140), rise = math.random(240, 460)}
		end
	end
	for i = #embers, 1, -1 do
		local e = embers[i]
		e.age = e.age + dt
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

local function loadClose()
	if loadClosed then return end
	loadClosed = true
	loadConn:Disconnect()
	lg:Destroy()
end
local function loadStep(p, text) target = p status.Text = text end
local function loadFinish()
	target = 1
	status.Text = "Pronto!"
	local t0 = os.clock()
	while shown < 0.999 and os.clock() - t0 < 6 do task.wait() end
	task.wait(0.3)
	loadClose()
end
task.delay(45, loadClose)
loadStep(0.15, "Carregando configurações...")

---------------------------------------------------------------- BOOST
local COR_CEU = Color3.fromRGB(140, 140, 145)
local COR_CHAO = Color3.fromRGB(60, 220, 40)
local ARVORES = {"tree", "arvore", "árvore", "leaf", "leaves", "foliage", "bush", "palm"}
local boostConns, boostAtm = {}, nil

local function inPlayer(o)
	local a = o
	while a and a ~= workspace do
		if a:IsA("Model") and Players:GetPlayerFromCharacter(a) then return true end
		a = a.Parent
	end
	return false
end
local function ehArvore(nome)
	nome = nome:lower()
	for _, n in ipairs(ARVORES) do
		if nome:find(n) then return true end
	end
	return false
end
local function boostObj(o)
	if o:IsA("Model") and ehArvore(o.Name) and not Players:GetPlayerFromCharacter(o) then
		o:Destroy()
		return
	end
	if inPlayer(o) then return end
	if o:IsA("Decal") or o:IsA("Texture") or o:IsA("SurfaceAppearance") then
		o:Destroy()
	elseif o:IsA("MeshPart") then
		o.CastShadow = false
		o.Material = Enum.Material.SmoothPlastic
		o.TextureID = ""
	elseif o:IsA("BasePart") then
		o.CastShadow = false
		o.Material = Enum.Material.SmoothPlastic
		if o.Name:lower():find("grass") then o.Color = COR_CHAO end
	end
end
local function enableBoost()
	pcall(function() Lighting.GlobalShadows = false end)
	Lighting.FogEnd = 9e9
	Lighting.Ambient = Color3.fromRGB(170, 170, 170)
	Lighting.OutdoorAmbient = Color3.fromRGB(170, 170, 170)
	Lighting.Brightness = 2
	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("Clouds") then v:Destroy() end
	end
	boostAtm = Instance.new("Atmosphere")
	boostAtm.Density, boostAtm.Offset, boostAtm.Glare, boostAtm.Haze = 1, 1, 0, 0
	boostAtm.Color, boostAtm.Decay = COR_CEU, COR_CEU
	boostAtm.Parent = Lighting
	boostConns[#boostConns + 1] = Lighting.ChildAdded:Connect(function(v)
		if v ~= boostAtm and (v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("Clouds")) then
			task.defer(function() pcall(function() v:Destroy() end) end)
		end
	end)
	Terrain.Decoration = false
	Terrain.WaterWaveSize, Terrain.WaterWaveSpeed, Terrain.WaterReflectance = 0, 0, 0
	for _, m in ipairs({Enum.Material.Grass, Enum.Material.LeafyGrass, Enum.Material.Ground, Enum.Material.Mud}) do
		pcall(function() Terrain:SetMaterialColor(m, COR_CHAO) end)
	end
	boostConns[#boostConns + 1] = workspace.DescendantAdded:Connect(function(o)
		task.defer(function() pcall(boostObj, o) end)
	end)
	local c = 0
	for _, o in ipairs(workspace:GetDescendants()) do
		pcall(boostObj, o)
		c = c + 1
		if c % 400 == 0 then task.wait() end
	end
end
local function disableBoost()
	for _, c in ipairs(boostConns) do c:Disconnect() end
	boostConns = {}
	if boostAtm then boostAtm:Destroy() boostAtm = nil end
	pcall(function() Lighting.GlobalShadows = true end)
end

---------------------------------------------------------------- NOMES E CHAT
local nameConns = {}
local function hideName(char)
	local h = char:WaitForChild("Humanoid", 10)
	if h then h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
end
local function enableNames()
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then task.spawn(hideName, p.Character) end
		nameConns[#nameConns + 1] = p.CharacterAdded:Connect(hideName)
	end
	nameConns[#nameConns + 1] = Players.PlayerAdded:Connect(function(p)
		nameConns[#nameConns + 1] = p.CharacterAdded:Connect(hideName)
	end)
end
local function disableNames()
	for _, c in ipairs(nameConns) do c:Disconnect() end
	nameConns = {}
	for _, p in ipairs(Players:GetPlayers()) do
		local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
		if h then h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
	end
end
local function setChatOff(v)
	pcall(function() SG:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not v) end)
	pcall(function() TextChatService.ChatWindowConfiguration.Enabled = not v end)
	pcall(function() TextChatService.ChatInputBarConfiguration.Enabled = not v end)
end

---------------------------------------------------------------- TELA ESTICADA
pcall(function() RunService:UnbindFromRenderStep("TigrimStretch") end)
RunService:BindToRenderStep("TigrimStretch", Enum.RenderPriority.Camera.Value + 1, function()
	if S.stretch then
		local cam = workspace.CurrentCamera
		cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, S.stretchVal, 0, 0, 0, 1)
	end
end)

---------------------------------------------------------------- SONS / BRILHO / DESTRUIÇÃO
env.TigrimVol = env.TigrimVol or setmetatable({}, {__mode = "k"})
local origVol = env.TigrimVol
local sndConn = {}
local cat = {glow = {en = {}, hid = {}}, dest = {en = {}, hid = {}}}
local EFFECT_FOLDERS = {_WorldOrigin = true, Effects = true, Debris = true}

local function isUi(o)
	return o:IsDescendantOf(lp.PlayerGui) or o:IsDescendantOf(CoreGui)
end
local function muteSound(s)
	if isUi(s) then return end
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
	for _, c in pairs(sndConn) do c:Disconnect() end
	sndConn = {}
	for s, v in pairs(origVol) do
		pcall(function() s.Volume = v end)
		origVol[s] = nil
	end
end
local function disableProp(c, o, prop)
	if c.en[o] == nil then c.en[o] = o[prop] end
	o[prop] = false
end
local function hidePart(c, o)
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
			if o.Name ~= "TigrimAura" then disableProp(cat.glow, o, "Enabled") end
		elseif o:IsA("PostEffect") then
			disableProp(cat.glow, o, "Enabled")
		elseif o:IsA("BasePart") and (o.Material == Enum.Material.Neon or o.Material == Enum.Material.ForceField)
			and not o.CanCollide and not inCharacter(o) then
			hidePart(cat.glow, o)
		end
	end
	if S.destroy then
		if o:IsA("Explosion") then
			disableProp(cat.dest, o, "Visible")
		elseif o:IsA("BasePart") or o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam")
			or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then
			if inEffectFolder(o) then
				if o:IsA("BasePart") then hidePart(cat.dest, o) else disableProp(cat.dest, o, "Enabled") end
			end
		end
	end
end
local function sweep()
	local n = 0
	for _, r in ipairs({workspace, Lighting, SoundService}) do
		for _, o in ipairs(r:GetDescendants()) do
			pcall(handle, o)
			n = n + 1
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
	if not env.TigrimHooked then
		env.TigrimHooked = true
		local wrap = newcclosure or function(f) return f end
		local old
		old = hookmetamethod(game, "__namecall", wrap(function(self, ...)
			local m = getnamecallmethod()
			local A = env.TigrimS
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
						if self.ClassName == "Sound" and not isUi(self) then
							if self.Volume > 0 then env.TigrimVol[self] = self.Volume end
							self.Volume = 0
						end
					end)
				end
			end
			return old(self, ...)
		end))
	end
end

---------------------------------------------------------------- AURA VERDE
local RANGE = 300
local auraFolder = Instance.new("Folder")
auraFolder.Name = "TigrimAuraFolder"
if not pcall(function() auraFolder.Parent = guiParent end) then auraFolder.Parent = workspace end
local auras = {}
local function removeAura(p)
	if auras[p] then auras[p]:Destroy() end
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
		n = n + 1
		if n % 20 == 0 then
			for s, c in pairs(sndConn) do
				if not s.Parent then c:Disconnect(); sndConn[s] = nil; origVol[s] = nil end
			end
		end
		task.wait(0.25)
	end
end)

---------------------------------------------------------------- PAINEL
local gui = Instance.new("ScreenGui")
gui.Name = "TigrimHub"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999

local fpsLabel
local onChange = {
	boost = function(v) if v then enableBoost() else disableBoost() end end,
	names = function(v) if v then enableNames() else disableNames() end end,
	chat = setChatOff,
	fps = function(v) if fpsLabel then fpsLabel.Visible = v end end,
	stretch = function() end,
	snd = function(v) if v then sweep() else unmuteAll() end end,
	glow = function(v) if v then sweep() else restore(cat.glow) end end,
	destroy = function(v) if v then sweep() else restore(cat.dest) end end,
	anim = function() end,
	aura = function(v) if not v then for p in pairs(auras) do removeAura(p) end end end,
	fpscap = function() if setfpscap then pcall(setfpscap, S.fpscap and 999 or 60) end end,
}
local ITEMS = {
	{"Boost gráfico (liso)", "boost"},
	{"Esconder nomes", "names"},
	{"Desativar chat", "chat"},
	{"Mostrar FPS", "fps"},
	{"Tela esticada", "stretch"},
	{"SLIDER"},
	{"Sem sons de ataque/skill", "snd"},
	{"Sem brilho", "glow"},
	{"Sem efeitos de destruição", "destroy"},
	{"Menu sem animação", "anim"},
	{"Aura verde (300)", "aura"},
	{"FPS sem limite", "fpscap"},
}

local function makeDraggable(handle, target)
	local info = {moved = false}
	local dragging, startPos, startFrame
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, info.moved = true, false
			startPos, startFrame = i.Position, target.Position
		end
	end)
	keep(UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - startPos
			if d.Magnitude > 6 then info.moved = true end
			target.Position = UDim2.new(startFrame.X.Scale, startFrame.X.Offset + d.X,
				startFrame.Y.Scale, startFrame.Y.Offset + d.Y)
		end
	end))
	keep(UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))
	return info
end

local function buildHub()
	gui.Parent = guiParent

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 250, 0, 330)
	main.Position = UDim2.new(0.5, -125, 0.5, -165)
	main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	main.BorderSizePixel = 0
	main.Active = true
	main.Parent = gui
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, 0, 0, 30)
	bar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	bar.BorderSizePixel = 0
	bar.Parent = main
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 8)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -40, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "Criador: TIGRIM021"
	title.TextColor3 = Color3.fromRGB(255, 200, 60)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent =
