if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local Debris = game:GetService("Debris")
local Terrain = workspace.Terrain

local lp = Players.LocalPlayer
while not lp do task.wait() lp = Players.LocalPlayer end

local env = (getgenv and getgenv()) or _G
if env.TigrimHubLoaded then return end
env.TigrimHubLoaded = true

---------------------------------------------------------------- CONFIG SALVA
local FILE = "TigrimHub_config.json"
local defaults = {
	fps = false, stretch = false, stretchVal = 0.7,
	fx = false, snd = false, anim = false,
	boost = true, names = true, chat = true,
}
local state = {}
for k, v in pairs(defaults) do state[k] = v end

pcall(function()
	if isfile and isfile(FILE) then
		local d = HttpService:JSONDecode(readfile(FILE))
		for k, v in pairs(d) do
			if defaults[k] ~= nil and type(v) == type(defaults[k]) then state[k] = v end
		end
	end
end)

local function save()
	pcall(function()
		if writefile then writefile(FILE, HttpService:JSONEncode(state)) end
	end)
end

---------------------------------------------------------------- PAI DA GUI
local okG, guiParent = pcall(function() return (gethui and gethui()) or game:GetService("CoreGui") end)
if not okG or not guiParent then guiParent = lp:WaitForChild("PlayerGui") end
pcall(function()
	for _, n in ipairs({"TigrimHub", "TigrimLoad"}) do
		if guiParent:FindFirstChild(n) then guiParent[n]:Destroy() end
	end
end)

---------------------------------------------------------------- TELA DE LOADING
local ORANGE = Color3.fromRGB(255, 130, 20)
local DARK = Color3.fromRGB(45, 30, 20)

local loadGui = Instance.new("ScreenGui")
loadGui.Name = "TigrimLoad"
loadGui.ResetOnSpawn = false
loadGui.IgnoreGuiInset = true
loadGui.DisplayOrder = 10000
loadGui.Parent = guiParent

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BorderSizePixel = 0
bg.Active = true
bg.Parent = loadGui

local center = Instance.new("Frame")
center.Size = UDim2.new(0, 220, 0, 220)
center.AnchorPoint = Vector2.new(0.5, 0.5)
center.Position = UDim2.new(0.5, 0, 0.5, 0)
center.BackgroundTransparency = 1
center.Parent = bg

local segs, N = {}, 60
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
orb.Size = UDim2.new(0, 90, 0, 90)
orb.AnchorPoint = Vector2.new(0.5, 0.5)
orb.Position = UDim2.new(0.5, 0, 0.5, 0)
orb.BackgroundColor3 = Color3.new(1, 1, 1)
orb.BorderSizePixel = 0
orb.Parent = center
Instance.new("UICorner", orb).CornerRadius = UDim.new(1, 0)
local orbGrad = Instance.new("UIGradient", orb)
orbGrad.Color = ColorSequence.new(Color3.fromRGB(255, 220, 90), Color3.fromRGB(230, 60, 10))
orbGrad.Rotation = 90
local orbStroke = Instance.new("UIStroke", orb)
orbStroke.Color = ORANGE
orbStroke.Thickness = 3

local pct = Instance.new("TextLabel")
pct.Size = UDim2.new(0, 200, 0, 34)
pct.AnchorPoint = Vector2.new(0.5, 0.5)
pct.Position = UDim2.new(0.5, 0, 0.5, 145)
pct.BackgroundTransparency = 1
pct.Text = "0%"
pct.TextColor3 = Color3.new(1, 1, 1)
pct.Font = Enum.Font.GothamBold
pct.TextSize = 28
pct.Parent = center

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0, 260, 0, 20)
status.AnchorPoint = Vector2.new(0.5, 0.5)
status.Position = UDim2.new(0.5, 0, 0.5, 175)
status.BackgroundTransparency = 1
status.Text = "Iniciando..."
status.TextColor3 = Color3.fromRGB(255, 190, 90)
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.Parent = center

local loading = true

task.spawn(function() -- pulsar da bola
	while loading do
		local t1 = TweenService:Create(orb, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{Size = UDim2.new(0, 102, 0, 102)})
		t1:Play(); t1.Completed:Wait()
		local t2 = TweenService:Create(orb, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{Size = UDim2.new(0, 90, 0, 90)})
		t2:Play(); t2.Completed:Wait()
	end
end)

local emberColors = {Color3.fromRGB(255, 140, 30), Color3.fromRGB(255, 200, 60), Color3.fromRGB(255, 80, 20)}
task.spawn(function() -- brasas subindo
	while loading do
		for _ = 1, 2 do
			local sz = math.random(3, 7)
			local x = math.random(-110, 110)
			local e = Instance.new("Frame")
			e.Size = UDim2.new(0, sz, 0, sz)
			e.AnchorPoint = Vector2.new(0.5, 0.5)
			e.Position = UDim2.new(0.5, x, 0.5, math.random(60, 140))
			e.BackgroundColor3 = emberColors[math.random(1, #emberColors)]
			e.BorderSizePixel = 0
			Instance.new("UICorner", e).CornerRadius = UDim.new(1, 0)
			e.Parent = bg
			local t = math.random(18, 30) / 10
			TweenService:Create(e, TweenInfo.new(t, Enum.EasingStyle.Sine), {
				Position = UDim2.new(0.5, x + math.random(-40, 40), 0.5, -math.random(180, 320)),
				BackgroundTransparency = 1,
			}):Play()
			Debris:AddItem(e, t + 0.1)
		end
		task.wait(0.1)
	end
end)

local target, shown, lit = 0, 0, 0
local loadConn = RunService.Heartbeat:Connect(function(dt)
	shown = math.min(target, shown + dt * 0.8)
	local n = math.floor(shown * N + 0.5)
	if n ~= lit then
		lit = n
		for i, s in ipairs(segs) do s.BackgroundColor3 = (i <= n) and ORANGE or DARK end
	end
	pct.Text = math.floor(shown * 100 + 0.5) .. "%"
end)

local function stepTo(p, text)
	target = p
	status.Text = text
	repeat task.wait() until shown >= p - 0.001
end

---------------------------------------------------------------- UTIL
local function inPlayer(o)
	local a = o
	while a and a ~= workspace do
		if a:IsA("Model") and Players:GetPlayerFromCharacter(a) then return true end
		a = a.Parent
	end
	return false
end

---------------------------------------------------------------- BOOST GRÁFICO
local COR_CEU = Color3.fromRGB(140, 140, 145)
local COR_CHAO = Color3.fromRGB(60, 220, 40)
local NOMES_ARVORE = {"tree", "arvore", "árvore", "leaf", "leaves", "foliage", "bush", "palm"}
local boostConns, boostAtm = {}, nil

local function ehArvore(nome)
	nome = nome:lower()
	for _, n in ipairs(NOMES_ARVORE) do
		if nome:find(n) then return true end
	end
	return false
end

local function boostObj(obj)
	if obj:IsA("Model") and ehArvore(obj.Name) and not Players:GetPlayerFromCharacter(obj) then
		obj:Destroy()
		return
	end
	if inPlayer(obj) then return end
	if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceAppearance") then
		obj:Destroy()
	elseif obj:IsA("MeshPart") then
		obj.CastShadow = false
		obj.Material = Enum.Material.SmoothPlastic
		obj.TextureID = ""
	elseif obj:IsA("BasePart") then
		obj.CastShadow = false
		obj.Material = Enum.Material.SmoothPlastic
		if obj.Name:lower():find("grass") then obj.Color = COR_CHAO end
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
	table.insert(boostConns, Lighting.ChildAdded:Connect(function(v)
		if v ~= boostAtm and (v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("Clouds")) then
			task.defer(function() pcall(function() v:Destroy() end) end)
		end
	end))

	Terrain.Decoration = false
	Terrain.WaterWaveSize, Terrain.WaterWaveSpeed, Terrain.WaterReflectance = 0, 0, 0
	for _, mat in ipairs({Enum.Material.Grass, Enum.Material.LeafyGrass, Enum.Material.Ground, Enum.Material.Mud}) do
		pcall(function() Terrain:SetMaterialColor(mat, COR_CHAO) end)
	end

	table.insert(boostConns, workspace.DescendantAdded:Connect(function(o)
		task.defer(function() pcall(boostObj, o) end)
	end))
	local c = 0
	for _, o in ipairs(workspace:GetDescendants()) do
		pcall(boostObj, o)
		c += 1
		if c % 400 == 0 then task.wait() end
	end
end

local function disableBoost()
	for _, c in ipairs(boostConns) do c:Disconnect() end
	boostConns = {}
	if boostAtm then boostAtm:Destroy() boostAtm = nil end
	pcall(function() Lighting.GlobalShadows = true end)
end

---------------------------------------------------------------- ESCONDER NOMES
local nameConns = {}
local function hideName(char)
	local hum = char:WaitForChild("Humanoid", 10)
	if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
end
local function enableNames()
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then task.spawn(hideName, p.Character) end
		table.insert(nameConns, p.CharacterAdded:Connect(hideName))
	end
	table.insert(nameConns, Players.PlayerAdded:Connect(function(p)
		table.insert(nameConns, p.CharacterAdded:Connect(hideName))
	end))
end
local function disableNames()
	for _, c in ipairs(nameConns) do c:Disconnect() end
	nameConns = {}
	for _, p in ipairs(Players:GetPlayers()) do
		local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
		if h then h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
	end
end

---------------------------------------------------------------- CHAT
local function setChatOff(v)
	pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not v) end)
	pcall(function() TextChatService.ChatWindowConfiguration.Enabled = not v end)
	pcall(function() TextChatService.ChatInputBarConfiguration.Enabled = not v end)
end

---------------------------------------------------------------- REMOVER EFEITOS
local fxTracked, fxConns = {}, {}
local effectFolders = {"_WorldOrigin", "Effects"}

local function killFx(o)
	if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") or o:IsA("Fire")
		or o:IsA("Smoke") or o:IsA("Sparkles") or o:IsA("Highlight") then
		if fxTracked[o] == nil then fxTracked[o] = o.Enabled end
		o.Enabled = false
	elseif o:IsA("Explosion") then
		o.Visible = false
	end
end
local function killFolderPart(o)
	if o:IsA("BasePart") then o.LocalTransparencyModifier = 1 end
	killFx(o)
end
local function enableFx()
	for _, o in ipairs(workspace:GetDescendants()) do pcall(killFx, o) end
	for _, name in ipairs(effectFolders) do
		local f = workspace:FindFirstChild(name)
		if f then for _, o in ipairs(f:GetDescendants()) do pcall(killFolderPart, o) end end
	end
	for _, e in ipairs(Lighting:GetChildren()) do
		if e:IsA("PostEffect") then
			if fxTracked[e] == nil then fxTracked[e] = e.Enabled end
			e.Enabled = false
		end
	end
	table.insert(fxConns, workspace.DescendantAdded:Connect(function(o)
		task.defer(function()
			pcall(killFx, o)
			for _, name in ipairs(effectFolders) do
				local f = workspace:FindFirstChild(name)
				if f and o:IsDescendantOf(f) then pcall(killFolderPart, o) end
			end
		end)
	end))
	table.insert(fxConns, Lighting.ChildAdded:Connect(function(e)
		if e:IsA("PostEffect") then e.Enabled = false end
	end))
end
local function disableFx()
	for _, c in ipairs(fxConns) do c:Disconnect() end
	fxConns = {}
	for o, was in pairs(fxTracked) do pcall(function() o.Enabled = was end) end
	fxTracked = {}
end

---------------------------------------------------------------- SONS
local origVol = {}
local function shouldPlay(s)
	local char = lp.Character
	if char and s:IsDescendantOf(char) then return true end
	local p = s.Parent
	local pos
	if p and p:IsA("BasePart") then pos = p.Position
	elseif p and p:IsA("Attachment") then pos = p.WorldPosition end
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if pos and root and (pos - root.Position).Magnitude <= 20 then
		local m = s:FindFirstAncestorOfClass("Model")
		if m and m ~= char and Players:GetPlayerFromCharacter(m) then return false end
		return true
	end
	return false
end
local function applySound(s)
	if origVol[s] == nil and s.Volume > 0 then origVol[s] = s.Volume end
	if shouldPlay(s) then
		if origVol[s] then s.Volume = origVol[s] end
	else
		s.Volume = 0
	end
end
task.spawn(function()
	while true do
		task.wait(0.3)
		if state.snd then
			for _, s in ipairs(SoundService:GetDescendants()) do
				if s:IsA("Sound") then pcall(function()
					if origVol[s] == nil and s.Volume > 0 then origVol[s] = s.Volume end
					s.Volume = 0
				end) end
			end
			for _, s in ipairs(workspace:GetDescendants()) do
				if s:IsA("Sound") then pcall(applySound, s) end
			end
		end
	end
end)

---------------------------------------------------------------- TELA ESTICADA
RunService:BindToRenderStep("TigrimStretch", Enum.RenderPriority.Camera.Value + 1, function()
	if state.stretch then
		local cam = workspace.CurrentCamera
		cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, state.stretchVal, 0, 0, 0, 1)
	end
end)

---------------------------------------------------------------- MENU SEM ANIMAÇÃO
if hookmetamethod and newcclosure and getnamecallmethod then
	local old
	old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
		if state.anim and self == TweenService and getnamecallmethod() == "Create" then
			local args = table.pack(...)
			local inst, info = args[1], args[2]
			if typeof(inst) == "Instance" and inst:IsA("GuiObject") and typeof(info) == "TweenInfo" then
				local sg = inst:FindFirstAncestorWhichIsA("ScreenGui")
				if not (sg and sg.Name:sub(1, 6) == "Tigrim") then
					args[2] = TweenInfo.new(0)
					return old(self, table.unpack(args, 1, args.n))
				end
			end
		end
		return old(self, ...)
	end))
end

---------------------------------------------------------------- HUB
local toggles = {}

local function buildHub()
	local gui = Instance.new("ScreenGui")
	gui.Name = "TigrimHub"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 999
	gui.Parent = guiParent

	local function makeDraggable(handle, targetFrame)
		local info = {moved = false}
		local dragging, startPos, startFramePos
		handle.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging, info.moved = true, false
				startPos, startFramePos = i.Position, targetFrame.Position
			end
		end)
		UIS.InputChanged:Connect(function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local d = i.Position - startPos
				if d.Magnitude > 6 then info.moved = true end
				targetFrame.Position = UDim2.new(startFramePos.X.Scale, startFramePos.X.Offset + d.X,
					startFramePos.Y.Scale, startFramePos.Y.Offset + d.Y)
			end
		end)
		UIS.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		return info
	end

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 250, 0, 340)
	main.Position = UDim2.new(0.5, -125, 0.5, -170)
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
	title.Parent = bar

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 26, 0, 22)
	closeBtn.Position = UDim2.new(1, -30, 0, 4)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14
	closeBtn.Parent = bar
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

	makeDraggable(bar, main)

	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.new(1, -16, 1, -40)
	list.Position = UDim2.new(0, 8, 0, 36)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 3
	list.CanvasSize = UDim2.new(0, 0, 0, 0)
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.Parent = main
	Instance.new("UIListLayout", list).Padding = UDim.new(0, 6)

	local mini = Instance.new("TextButton")
	mini.Size = UDim2.new(0, 40, 0, 40)
	mini.Position = UDim2.new(0, 10, 0.5, 0)
	mini.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
	mini.Text = "T"
	mini.TextColor3 = Color3.new(0, 0, 0)
	mini.Font = Enum.Font.GothamBold
	mini.TextSize = 20
	mini.Visible = false
	mini.Parent = gui
	Instance.new("UICorner", mini).CornerRadius = UDim.new(1, 0)
	local miniDrag = makeDraggable(mini, mini)

	closeBtn.Activated:Connect(function() main.Visible = false; mini.Visible = true end)
	mini.Activated:Connect(function()
		if miniDrag.moved then return end
		mini.Visible = false; main.Visible = true
	end)

	local function makeToggle(text, key, fn)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, 0, 0, 32)
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Font = Enum.Font.Gotham
		b.TextSize = 13
		b.Parent = list
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		local function refresh()
			b.Text = text .. ":  " .. (state[key] and "ON" or "OFF")
			b.BackgroundColor3 = state[key] and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(45, 45, 55)
		end
		b.Activated:Connect(function()
			state[key] = not state[key]
			refresh()
			pcall(fn, state[key])
			save()
		end)
		refresh()
		table.insert(toggles, function() if state[key] then pcall(fn, true) end end)
	end

	-- FPS
	local fpsLabel = Instance.new("TextLabel")
	fpsLabel.Size = UDim2.new(0, 170, 0, 22)
	fpsLabel.Position = UDim2.new(0, 70, 0, 6)
	fpsLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	fpsLabel.BackgroundTransparency = 0.5
	fpsLabel.TextColor3 = Color3.new(1, 1, 1)
	fpsLabel.Font = Enum.Font.Code
	fpsLabel.TextSize = 14
	fpsLabel.Text = "FPS: -- | -- ms"
	fpsLabel.Visible = false
	fpsLabel.Parent = gui
	local fr, tm = 0, 0
	RunService.RenderStepped:Connect(function(dt)
		if not state.fps then return end
		fr += 1; tm += dt
		if tm >= 0.5 then
			fpsLabel.Text = string.format("FPS: %.1f | %.1f ms", fr / tm, (tm / fr) * 1000)
			fr, tm = 0, 0
		end
	end)

	makeToggle("Boost gráfico (liso)", "boost", function(v) if v then enableBoost() else disableBoost() end end)
	makeToggle("Esconder nomes", "names", function(v) if v then enableNames() else disableNames() end end)
	makeToggle("Desativar chat", "chat", setChatOff)
	makeToggle("Mostrar FPS", "fps", function(v) fpsLabel.Visible = v end)
	makeToggle("Tela esticada", "stretch", function() end)

	-- Slider
	local sRow = Instance.new("Frame")
	sRow.Size = UDim2.new(1, 0, 0, 46)
	sRow.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	sRow.Parent = list
	Instance.new("UICorner", sRow).CornerRadius = UDim.new(0, 6)

	local sLabel = Instance.new("TextLabel")
	sLabel.Size = UDim2.new(1, -10, 0, 20)
	sLabel.Position = UDim2.new(0, 8, 0, 3)
	sLabel.BackgroundTransparency = 1
	sLabel.TextColor3 = Color3.new(1, 1, 1)
	sLabel.Font = Enum.Font.Gotham
	sLabel.TextSize = 12
	sLabel.TextXAlignment = Enum.TextXAlignment.Left
	sLabel.Parent = sRow

	local sBar = Instance.new("Frame")
	sBar.Size = UDim2.new(1, -20, 0, 8)
	sBar.Position = UDim2.new(0, 10, 0, 30)
	sBar.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
	sBar.BorderSizePixel = 0
	sBar.Parent = sRow
	Instance.new("UICorner", sBar).CornerRadius = UDim.new(1, 0)

	local sFill = Instance.new("Frame")
	sFill.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
	sFill.BorderSizePixel = 0
	sFill.Parent = sBar
	Instance.new("UICorner", sFill).CornerRadius = UDim.new(1, 0)

	local MIN, MAX = 0.4, 1.0
	local function setSlider(rel)
		rel = math.clamp(rel, 0, 1)
		state.stretchVal = MIN + rel * (MAX - MIN)
		sFill.Size = UDim2.new(rel, 0, 1, 0)
		sLabel.Text = string.format("Intensidade da esticada: %d%%", math.floor((1 - state.stretchVal) / (1 - MIN) * 100 + 0.5))
	end
	setSlider((state.stretchVal - MIN) / (MAX - MIN))

	local sDrag = false
	sRow.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sDrag = true
			setSlider((i.Position.X - sBar.AbsolutePosition.X) / sBar.AbsoluteSize.X)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if sDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			setSlider((i.Position.X - sBar.AbsolutePosition.X) / sBar.AbsoluteSize.X)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if sDrag and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
			sDrag = false
			save()
		end
	end)

	makeToggle("Remover efeitos (raio/explosão)", "fx", function(v) if v then enableFx() else disableFx() end end)
	makeToggle("Remover sons/música", "snd", function(v)
		if not v then for s, vol in pairs(origVol) do pcall(function() s.Volume = vol end) end end
	end)
	makeToggle("Menu sem animação", "anim", function() end)
end

---------------------------------------------------------------- INICIALIZAÇÃO
task.spawn(function()
	stepTo(0.15, "Carregando configurações...")

	local t0 = os.clock()
	while not lp.Character and os.clock() - t0 < 10 do task.wait() end
	lp:WaitForChild("PlayerGui", 10)
	stepTo(0.4, "Esperando o jogo...")

	buildHub()
	stepTo(0.6, "Montando o hub...")

	for _, apply in ipairs(toggles) do
		apply()
		task.wait()
	end
	stepTo(0.9, "Aplicando suas opções...")

	stepTo(1, "Pronto!")
	task.wait(0.3)

	loading = false
	loadConn:Disconnect()
	center.Visible = false
	for _, c in ipairs(bg:GetChildren()) do
		if c ~= center then c:Destroy() end
	end
	local t = TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1})
	t:Play(); t.Completed:Wait()
	loadGui:Destroy()
end)
