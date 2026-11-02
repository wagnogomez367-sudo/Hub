if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local Terrain = workspace.Terrain
local lp = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G

if env.TigrimHubStop then pcall(env.TigrimHubStop) end
local L = env.TigrimLoad or {step = function() end, finish = function() end}
L.step(0.15, "Carregando configurações...")

---------------------------------------------------------------- CONFIG
local FILE = "TigrimHub_config.json"
local defaults = {fps = false, stretch = false, stretchVal = 0.7, boost = true, names = true, chat = true}
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
	pcall(function() if writefile then writefile(FILE, HttpService:JSONEncode(state)) end end)
end

local okG, guiParent = pcall(function() return (gethui and gethui()) or game:GetService("CoreGui") end)
if not okG or not guiParent then guiParent = lp:WaitForChild("PlayerGui") end
pcall(function()
	local o = guiParent:FindFirstChild("TigrimHub")
	if o then o:Destroy() end
end)

local conns = {}
local function keep(c) table.insert(conns, c) return c end

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
	table.insert(boostConns, Lighting.ChildAdded:Connect(function(v)
		if v ~= boostAtm and (v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("Clouds")) then
			task.defer(function() pcall(function() v:Destroy() end) end)
		end
	end))
	Terrain.Decoration = false
	Terrain.WaterWaveSize, Terrain.WaterWaveSpeed, Terrain.WaterReflectance = 0, 0, 0
	for _, m in ipairs({Enum.Material.Grass, Enum.Material.LeafyGrass, Enum.Material.Ground, Enum.Material.Mud}) do
		pcall(function() Terrain:SetMaterialColor(m, COR_CHAO) end)
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

---------------------------------------------------------------- NOMES
local nameConns = {}
local function hideName(char)
	local h = char:WaitForChild("Humanoid", 10)
	if h then h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
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

---------------------------------------------------------------- TELA ESTICADA
pcall(function() RunService:UnbindFromRenderStep("TigrimStretch") end)
RunService:BindToRenderStep("TigrimStretch", Enum.RenderPriority.Camera.Value + 1, function()
	if state.stretch then
		local cam = workspace.CurrentCamera
		cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, state.stretchVal, 0, 0, 0, 1)
	end
end)

---------------------------------------------------------------- HUB
local toggles = {}
local gui = Instance.new("ScreenGui")
gui.Name = "TigrimHub"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999

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
	main.Size = UDim2.new(0, 250, 0, 300)
	main.Position = UDim2.new(0.5, -125, 0.5, -150)
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
			task.spawn(function() pcall(fn, state[key]) end)
			save()
		end)
		refresh()
		table.insert(toggles, function() if state[key] then pcall(fn, true) end end)
	end

	-- contador de FPS
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
	keep(RunService.RenderStepped:Connect(function(dt)
		if not state.fps then return end
		fr += 1; tm += dt
		if tm >= 0.5 then
			fpsLabel.Text = string.format("FPS: %.1f | %.1f ms", fr / tm, (tm / fr) * 1000)
			fr, tm = 0, 0
		end
	end))

	makeToggle("Boost gráfico (liso)", "boost", function(v) if v then enableBoost() else disableBoost() end end)
	makeToggle("Esconder nomes", "names", function(v) if v then enableNames() else disableNames() end end)
	makeToggle("Desativar chat", "chat", setChatOff)
	makeToggle("Mostrar FPS", "fps", function(v) fpsLabel.Visible = v end)
	makeToggle("Tela esticada", "stretch", function() end)

	-- barra da tela esticada
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
		sLabel.Text = string.format("Intensidade da esticada: %d%%",
			math.floor((1 - state.stretchVal) / (1 - MIN) * 100 + 0.5))
	end
	setSlider((state.stretchVal - MIN) / (MAX - MIN))

	local sDrag = false
	sRow.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sDrag = true
			setSlider((i.Position.X - sBar.AbsolutePosition.X) / sBar.AbsoluteSize.X)
		end
	end)
	keep(UIS.InputChanged:Connect(function(i)
		if sDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			setSlider((i.Position.X - sBar.AbsolutePosition.X) / sBar.AbsoluteSize.X)
		end
	end))
	keep(UIS.InputEnded:Connect(function(i)
		if sDrag and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
			sDrag = false
			save()
		end
	end))
end

env.TigrimHubStop = function()
	for _, c in ipairs(conns) do c:Disconnect() end
	pcall(function() RunService:UnbindFromRenderStep("TigrimStretch") end)
	pcall(function() gui:Destroy() end)
end

---------------------------------------------------------------- INICIAR
task.spawn(function()
	local t0 = os.clock()
	while not lp.Character and os.clock() - t0 < 10 do task.wait() end
	L.step(0.4, "Montando o hub...")
	local ok, err = pcall(buildHub)
	if not ok then warn("[Tigrim Hub] erro: " .. tostring(err)) end
	L.step(0.7, "Aplicando suas opções...")
	for _, apply in ipairs(toggles) do task.spawn(apply) end
	task.wait(1)
	L.finish()
end)
