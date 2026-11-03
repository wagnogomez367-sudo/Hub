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

local function mk(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end
local function round(o, r) mk("UICorner", {CornerRadius = UDim.new(0, r)}, o) end
local function isPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function isMove(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

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

local lg = mk("ScreenGui", {Name = "TigrimLoad", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 10000}, guiParent)
local bg = mk("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Active = true}, lg)
local center = mk("Frame", {
	Size = UDim2.new(0, 220, 0, 220), AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1,
}, bg)

local N = 48
local segs = {}
for i = 1, N do
	local a = (i - 1) / N * math.pi * 2 - math.pi / 2
	segs[i] = mk("Frame", {
		Size = UDim2.new(0, 4, 0, 14), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, math.cos(a) * 95, 0.5, math.sin(a) * 95),
		Rotation = math.deg(a) + 90, BackgroundColor3 = DARK, BorderSizePixel = 0,
	}, center)
end

local orb = mk("Frame", {
	Size = UDim2.new(0, 96, 0, 96), AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
}, center)
round(orb, 60)
mk("UIGradient", {
	Color = ColorSequence.new(Color3.fromRGB(255, 220, 90), Color3.fromRGB(230, 60, 10)), Rotation = 90,
}, orb)
mk("UIStroke", {Color = ORANGE, Thickness = 3}, orb)

local function mkLabel(y, size, font, color)
	return mk("TextLabel", {
		Size = UDim2.new(0, 260, 0, size + 6), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, y), BackgroundTransparency = 1,
		TextColor3 = color, Font = font, TextSize = size,
	}, center)
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
			local f = mk("Frame", {
				Size = UDim2.new(0, s, 0, s), AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = EMBER[math.random(1, #EMBER)], BorderSizePixel = 0,
			}, bg)
			round(f, 10)
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
local function isSkyLike(v)
	return v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("Clouds")
end
local function enableBoost()
	pcall(function() Lighting.GlobalShadows = false end)
	Lighting.FogEnd = 9e9
	Lighting.Ambient = Color3.fromRGB(170, 170, 170)
	Lighting.OutdoorAmbient = Color3.fromRGB(170, 170, 170)
	Lighting.Brightness = 2
	for _, v in ipairs(Lighting:GetChildren()) do
		if isSkyLike(v) then v:Destroy() end
	end
	boostAtm = mk("Atmosphere", {Density = 1, Offset = 1, Glare = 0, Haze = 0, Color = COR_CEU, Decay = COR_CEU}, Lighting)
	boostConns[#boostConns + 1] = Lighting.ChildAdded:Connect(function(v)
		if v ~= boostAtm and isSkyLike(v) then
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
							local a, b, _, _, _, f, g = ...
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
		if isPress(i) then
			dragging, info.moved = true, false
			startPos, startFrame = i.Position, target.Position
		end
	end)
	keep(UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then
			local d = i.Position - startPos
			if d.Magnitude > 6 then info.moved = true end
			target.Position = UDim2.new(startFrame.X.Scale, startFrame.X.Offset + d.X,
				startFrame.Y.Scale, startFrame.Y.Offset + d.Y)
		end
	end))
	keep(UIS.InputEnded:Connect(function(i)
		if isPress(i) then dragging = false end
	end))
	return info
end

local function buildSlider(list, order)
	local sRow = mk("Frame", {LayoutOrder = order, Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Color3.fromRGB(45, 45, 55)}, list)
	round(sRow, 6)
	local sLabel = mk("TextLabel", {
		Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 8, 0, 3), BackgroundTransparency = 1,
		TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Gotham, TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, sRow)
	local sBar = mk("Frame", {
		Size = UDim2.new(1, -20, 0, 8), Position = UDim2.new(0, 10, 0, 30),
		BackgroundColor3 = Color3.fromRGB(80, 80, 90), BorderSizePixel = 0,
	}, sRow)
	round(sBar, 4)
	local sFill = mk("Frame", {BackgroundColor3 = Color3.fromRGB(255, 200, 60), BorderSizePixel = 0}, sBar)
	round(sFill, 4)

	local MIN, MAX = 0.4, 1.0
	local function setSlider(rel)
		rel = math.clamp(rel, 0, 1)
		S.stretchVal = MIN + rel * (MAX - MIN)
		sFill.Size = UDim2.new(rel, 0, 1, 0)
		sLabel.Text = string.format("Intensidade da esticada: %d%%",
			math.floor((1 - S.stretchVal) / (1 - MIN) * 100 + 0.5))
	end
	setSlider((S.stretchVal - MIN) / (MAX - MIN))

	local sDrag = false
	sRow.InputBegan:Connect(function(inp)
		if isPress(inp) then
			sDrag = true
			setSlider((inp.Position.X - sBar.AbsolutePosition.X) / sBar.AbsoluteSize.X)
		end
	end)
	keep(UIS.InputChanged:Connect(function(inp)
		if sDrag and isMove(inp) then
			setSlider((inp.Position.X - sBar.AbsolutePosition.X) / sBar.AbsoluteSize.X)
		end
	end))
	keep(UIS.InputEnded:Connect(function(inp)
		if sDrag and isPress(inp) then
			sDrag = false
			save()
		end
	end))
end

local function buildHub()
	gui.Parent = guiParent

	local main = mk("Frame", {
		Size = UDim2.new(0, 250, 0, 330), Position = UDim2.new(0.5, -125, 0.5, -165),
		BackgroundColor3 = Color3.fromRGB(25, 25, 30), BorderSizePixel = 0, Active = true,
	}, gui)
	round(main, 8)

	local bar = mk("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(40, 40, 50), BorderSizePixel = 0}, main)
	round(bar, 8)
	mk("TextLabel", {
		Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1,
		Text = "Criador: TIGRIM021", TextColor3 = Color3.fromRGB(255, 200, 60),
		Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
	}, bar)
	local closeBtn = mk("TextButton", {
		Size = UDim2.new(0, 26, 0, 22), Position = UDim2.new(1, -30, 0, 4),
		BackgroundColor3 = Color3.fromRGB(200, 50, 50), Text = "X", TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold, TextSize = 14,
	}, bar)
	round(closeBtn, 6)
	makeDraggable(bar, main)

	local list = mk("ScrollingFrame", {
		Size = UDim2.new(1, -16, 1, -40), Position = UDim2.new(0, 8, 0, 36), BackgroundTransparency = 1,
		BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, main)
	mk("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, list)

	local mini = mk("TextButton", {
		Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 10, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 200, 60), Text = "T", TextColor3 = Color3.new(0, 0, 0),
		Font = Enum.Font.GothamBold, TextSize = 20, Visible = false,
	}, gui)
	round(mini, 20)
	local miniDrag = makeDraggable(mini, mini)
	closeBtn.Activated:Connect(function() main.Visible = false; mini.Visible = true end)
	mini.Activated:Connect(function()
		if miniDrag.moved then return end
		mini.Visible = false; main.Visible = true
	end)

	fpsLabel = mk("TextLabel", {
		Size = UDim2.new(0, 170, 0, 22), Position = UDim2.new(0, 70, 0, 6),
		BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5,
		TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Code, TextSize = 14,
		Text = "FPS: -- | -- ms", Visible = S.fps,
	}, gui)
	local fr, ft = 0, 0
	keep(RunService.RenderStepped:Connect(function(dt)
		if not S.fps then return end
		fr = fr + 1; ft = ft + dt
		if ft >= 0.5 then
			fpsLabel.Text = string.format("FPS: %.1f | %.1f ms", fr / ft, (ft / fr) * 1000)
			fr, ft = 0, 0
		end
	end))

	for i, it in ipairs(ITEMS) do
		if it[1] == "SLIDER" then
			buildSlider(list, i)
		else
			local text, key = it[1], it[2]
			local b = mk("TextButton", {
				LayoutOrder = i, Size = UDim2.new(1, 0, 0, 32), TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham, TextSize = 13,
			}, list)
			round(b, 6)
			local function refresh()
				b.Text = text .. ":  " .. (S[key] and "ON" or "OFF")
				b.BackgroundColor3 = S[key] and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(45, 45, 55)
			end
			b.Activated:Connect(function()
				S[key] = not S[key]
				refresh()
				task.spawn(function() pcall(onChange[key], S[key]) end)
				save()
			end)
			refresh()
		end
	end
end

env.TigrimStop = function()
	alive = false
	for _, c in ipairs(conns) do c:Disconnect() end
	pcall(function() RunService:UnbindFromRenderStep("TigrimStretch") end)
	unmuteAll()
	restore(cat.glow)
	restore(cat.dest)
	for p in pairs(auras) do removeAura(p) end
	pcall(function() gui:Destroy() end)
	pcall(function() auraFolder:Destroy() end)
	pcall(loadClose)
end

---------------------------------------------------------------- INICIAR
task.spawn(function()
	local t0 = os.clock()
	while not lp.Character and os.clock() - t0 < 10 do task.wait() end
	loadStep(0.4, "Montando o hub...")
	local ok2, e2 = pcall(buildHub)
	if not ok2 then notify("Erro no hub: " .. tostring(e2)) end
	loadStep(0.7, "Aplicando suas opções...")
	for _, it in ipairs(ITEMS) do
		local key = it[2]
		if key and S[key] and onChange[key] then
			task.spawn(function()
				local ok3, e3 = pcall(onChange[key], true)
				if not ok3 then warn("[Tigrim] " .. key .. ": " .. tostring(e3)) end
			end)
		end
	end
	task.wait(1)
	loadFinish()
	if not hooked then
		notify("Seu executor não tem hookmetamethod: menu sem animação e parte dos sons podem não funcionar.")
	end
end)
end)

if not ok then
	warn("[Tigrim] ERRO: " .. tostring(err))
	notify("ERRO: " .. tostring(err))
end
-- FIM
