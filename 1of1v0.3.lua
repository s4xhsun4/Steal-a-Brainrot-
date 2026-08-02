--[[
  S4XH 1 Of 1 — X BONITO E FUNCIONAL
  - X com estilo minimalista (apenas texto, sem fundo)
  - Verifica se o jogo é 7709344486, se não for kick
  - Lógica do banner e seleção permanecem inalteradas
]]

-- VERIFICAÇÃO DE JOGO
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ALLOWED_UNIVERSE_ID = 7709344486

if game.GameId ~= ALLOWED_UNIVERSE_ID then
    player:Kick("Game Not Authorized")
    return
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = player

-------------------------------------------------
-- 0. HOOKS DO BRAINROTCARD
-------------------------------------------------
local forcedOneOfOne = {}

local BrainrotCard = ReplicatedStorage:FindFirstChild("Shared")
	and ReplicatedStorage.Shared:FindFirstChild("BrainrotCard")
	and require(ReplicatedStorage.Shared.BrainrotCard)

if BrainrotCard then
	local oldIsOneOfOne
	oldIsOneOfOne = hookfunction(BrainrotCard.IsOneOfOne, function(record)
		if forcedOneOfOne[record.Index] then return true end
		return oldIsOneOfOne(record)
	end)
	local oldObserve
	oldObserve = hookfunction(BrainrotCard.ObserveOneOfOne, function(record, callback)
		return oldObserve(record, function(value)
			if forcedOneOfOne[record.Index] then callback(true) else callback(value) end
		end)
	end)
else
	warn("[S4XH] BrainrotCard não encontrado.")
end

-------------------------------------------------
-- 1. BRAINROTS VÁLIDOS (ReplicatedStorage)
-------------------------------------------------
local function getValidBrainrotNames()
	local animals = ReplicatedStorage:FindFirstChild("Animations")
		and ReplicatedStorage.Animations:FindFirstChild("Animals")
	if not animals then return {} end
	local names = {}
	for _, child in pairs(animals:GetChildren()) do
		table.insert(names, child.Name)
	end
	return names
end

local validBrainrots = getValidBrainrotNames()

local function isValidBrainrot(name)
	for _, v in pairs(validBrainrots) do
		if v == name then return true end
	end
	return false
end

-------------------------------------------------
-- 2. AUXILIARES DE UI
-------------------------------------------------
local function corner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius or UDim.new(0, 8)
	c.Parent = obj
	return c
end

local function stroke(obj, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(255,255,255)
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = obj
	return s
end

local function tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-------------------------------------------------
-- 3. PALETA DE CORES (VERMELHO)
-------------------------------------------------
local palette = {
	bgMain    = Color3.fromRGB(12, 16, 24),
	bgCard    = Color3.fromRGB(22, 30, 42),
	bgHover   = Color3.fromRGB(32, 42, 58),
	accent    = Color3.fromRGB(220, 50, 50),
	accentDim = Color3.fromRGB(180, 40, 40),
	text      = Color3.fromRGB(220, 235, 250),
	textMuted = Color3.fromRGB(120, 150, 180),
	green     = Color3.fromRGB(80, 220, 140),
	glass     = Color3.fromRGB(255, 255, 255),
}

-------------------------------------------------
-- 4. GUI PRINCIPAL
-------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "S4XH_OneOfOne"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 99
gui.IgnoreGuiInset = true
gui.Parent = localPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 340, 0, 180)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.BackgroundColor3 = palette.bgMain
main.BackgroundTransparency = 0.1
main.ClipsDescendants = true
main.Active = true
main.Parent = gui
corner(main, UDim.new(0, 12))
stroke(main, palette.accent, 1.5)

local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, palette.bgMain),
	ColorSequenceKeypoint.new(1, palette.bgCard),
})
bgGrad.Parent = main

-------------------------------------------------
-- 5. BARRA DE TÍTULO
-------------------------------------------------
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 34)
titleBar.BackgroundTransparency = 1
titleBar.Active = true
titleBar.Selectable = true
titleBar.Parent = main

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextColor3 = palette.text
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = "S4XH 1 Of 1"
titleLabel.Parent = titleBar

-------------------------------------------------
-- X BOTÃO CORRIGIDO (APENAS TEXTO, SEM FUNDO, SEM BORDA)
-------------------------------------------------
local close = Instance.new("TextLabel")
close.Size = UDim2.new(0, 32, 0, 32)
close.Position = UDim2.new(1, -10, 0.5, 0)
close.AnchorPoint = Vector2.new(1, 0.5)
close.BackgroundTransparency = 1
close.Text = "X"
close.TextColor3 = Color3.fromRGB(180, 180, 190)
close.TextSize = 18
close.Font = Enum.Font.GothamBold
close.TextXAlignment = Enum.TextXAlignment.Center
close.TextYAlignment = Enum.TextYAlignment.Center
close.Parent = titleBar

-- Botão invisível por cima para capturar cliques
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -10, 0.5, 0)
closeBtn.AnchorPoint = Vector2.new(1, 0.5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = ""
closeBtn.Parent = titleBar

closeBtn.MouseEnter:Connect(function()
	TweenService:Create(close, TweenInfo.new(0.1), { TextColor3 = Color3.fromRGB(255, 100, 100) }):Play()
end)

closeBtn.MouseLeave:Connect(function()
	TweenService:Create(close, TweenInfo.new(0.1), { TextColor3 = Color3.fromRGB(180, 180, 190) }):Play()
end)

closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-------------------------------------------------
-- 6. CONTEÚDO
-------------------------------------------------
local contentFrame = Instance.new("Frame")
contentFrame.Position = UDim2.new(0, 0, 0, 34)
contentFrame.Size = UDim2.new(1, 0, 1, -34)
contentFrame.BackgroundTransparency = 1
contentFrame.ClipsDescendants = true
contentFrame.Parent = main

-------------------------------------------------
-- 7. SCROLL E LISTA
-------------------------------------------------
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -70)
scroll.Position = UDim2.new(0, 0, 0, 0)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = palette.accent
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.Parent = contentFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = scroll

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 8)
pad.PaddingBottom = UDim.new(0, 8)
pad.PaddingLeft = UDim.new(0, 8)
pad.PaddingRight = UDim.new(0, 8)
pad.Parent = scroll

-------------------------------------------------
-- 8. BOTÕES INFERIORES
-------------------------------------------------
local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.new(0, 90, 0, 28)
applyBtn.AnchorPoint = Vector2.new(1, 1)
applyBtn.Position = UDim2.new(1, -10, 1, -8)
applyBtn.BackgroundColor3 = palette.accent
applyBtn.BackgroundTransparency = 0.2
applyBtn.Text = "Apply"
applyBtn.TextColor3 = Color3.fromRGB(255,255,255)
applyBtn.TextSize = 13
applyBtn.Font = Enum.Font.GothamBold
applyBtn.BorderSizePixel = 0
applyBtn.ZIndex = 5
applyBtn.Parent = contentFrame
corner(applyBtn, UDim.new(0, 6))
stroke(applyBtn, palette.accent, 1)

local removeBtn = Instance.new("TextButton")
removeBtn.Size = UDim2.new(0, 90, 0, 28)
removeBtn.AnchorPoint = Vector2.new(0, 1)
removeBtn.Position = UDim2.new(0, 10, 1, -8)
removeBtn.BackgroundColor3 = palette.accent
removeBtn.BackgroundTransparency = 0.15
removeBtn.Text = "Remove"
removeBtn.TextColor3 = Color3.fromRGB(255,255,255)
removeBtn.TextSize = 13
removeBtn.Font = Enum.Font.GothamBold
removeBtn.BorderSizePixel = 0
removeBtn.ZIndex = 5
removeBtn.Parent = contentFrame
corner(removeBtn, UDim.new(0, 6))
stroke(removeBtn, palette.accent, 0.8)

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0, 60, 0, 28)
clearBtn.AnchorPoint = Vector2.new(0.5, 1)
clearBtn.Position = UDim2.new(0.5, 0, 1, -8)
clearBtn.BackgroundColor3 = palette.bgCard
clearBtn.BackgroundTransparency = 0.3
clearBtn.Text = "Clear"
clearBtn.TextColor3 = palette.textMuted
clearBtn.TextSize = 12
clearBtn.Font = Enum.Font.GothamBold
clearBtn.BorderSizePixel = 0
clearBtn.ZIndex = 5
clearBtn.Parent = contentFrame
corner(clearBtn, UDim.new(0, 6))
stroke(clearBtn, palette.accentDim, 0.5)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -220, 0, 28)
status.Position = UDim2.new(0, 80, 1, -8)
status.AnchorPoint = Vector2.new(0, 1)
status.BackgroundTransparency = 1
status.TextColor3 = palette.textMuted
status.TextSize = 11
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Text = "Aguardando plot…"
status.ZIndex = 5
status.Parent = contentFrame

-------------------------------------------------
-- 9. DRAG
-------------------------------------------------
do
	local dragging, dragStart, startPos = false
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		dragging = true
		dragStart = input.Position
		startPos = main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end)
end

-------------------------------------------------
-- 10. LISTA DE ITENS (COM PERSISTÊNCIA)
-------------------------------------------------
local selectedMap = {}
local savedSelections = {}
local itemMap = {}

local function clearItems()
	savedSelections = {}
	for name, state in pairs(selectedMap) do
		if state then
			table.insert(savedSelections, name)
		end
	end
	for _, c in pairs(scroll:GetChildren()) do
		if c:IsA("Frame") then
			c:Destroy()
		end
	end
	itemMap = {}
	selectedMap = {}
end

local function toggleSelection(name)
	local data = itemMap[name]
	if not data then return end
	
	local row = data.row
	local check = row:FindFirstChild("CheckLabel")
	local newState = not selectedMap[name]
	selectedMap[name] = newState
	
	if check then
		check.Visible = newState
	end
	
	if newState then
		tween(row, { BackgroundTransparency = 0.2 }, 0.1)
	else
		tween(row, { BackgroundTransparency = 0.5 }, 0.1)
	end
	
	local count = 0
	for _ in pairs(selectedMap) do if selectedMap[_] then count = count + 1 end end
	if count > 0 then
		status.Text = count .. " selecionado(s)"
		status.TextColor3 = palette.green
	else
		status.Text = "Nenhum selecionado"
		status.TextColor3 = palette.textMuted
	end
end

local function createItem(name, gen, overhead, idx)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 32)
	row.BackgroundColor3 = palette.bgCard
	row.BackgroundTransparency = 0.5
	row.LayoutOrder = idx
	row.Parent = scroll
	corner(row, UDim.new(0, 6))
	stroke(row, palette.accentDim, 0.5)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.65, 0, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextColor3 = palette.text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = name
	label.Parent = row

	local genLabel = Instance.new("TextLabel")
	genLabel.Size = UDim2.new(0.25, 0, 1, 0)
	genLabel.Position = UDim2.new(0.65, 0, 0, 0)
	genLabel.BackgroundTransparency = 1
	genLabel.Font = Enum.Font.Gotham
	genLabel.TextSize = 11
	genLabel.TextColor3 = palette.green
	genLabel.TextXAlignment = Enum.TextXAlignment.Right
	genLabel.Text = gen
	genLabel.Parent = row

	local check = Instance.new("TextLabel")
	check.Name = "CheckLabel"
	check.Size = UDim2.new(0, 24, 0, 24)
	check.AnchorPoint = Vector2.new(1, 0.5)
	check.Position = UDim2.new(1, -8, 0.5, 0)
	check.BackgroundTransparency = 1
	check.Font = Enum.Font.GothamBlack
	check.TextSize = 18
	check.TextColor3 = palette.accent
	check.Text = "☑"
	check.TextXAlignment = Enum.TextXAlignment.Center
	check.TextYAlignment = Enum.TextYAlignment.Center
	check.Visible = false
	check.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromScale(1, 1)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.ZIndex = 2
	btn.Parent = row

	btn.MouseButton1Click:Connect(function()
		toggleSelection(name)
	end)

	row.MouseEnter:Connect(function()
		if not selectedMap[name] then
			tween(row, { BackgroundTransparency = 0.3 }, 0.1)
		end
	end)
	row.MouseLeave:Connect(function()
		if not selectedMap[name] then
			tween(row, { BackgroundTransparency = 0.5 }, 0.1)
		end
	end)

	selectedMap[name] = false
	itemMap[name] = { row = row, overhead = overhead }
end

local function restoreSelections()
	for _, name in pairs(savedSelections) do
		if itemMap[name] then
			selectedMap[name] = true
			local data = itemMap[name]
			local check = data.row:FindFirstChild("CheckLabel")
			if check then
				check.Visible = true
			end
			tween(data.row, { BackgroundTransparency = 0.2 }, 0.1)
		end
	end
	savedSelections = {}
	local count = 0
	for _ in pairs(selectedMap) do if selectedMap[_] then count = count + 1 end end
	if count > 0 then
		status.Text = count .. " selecionado(s)"
		status.TextColor3 = palette.green
	else
		status.Text = "Nenhum selecionado"
		status.TextColor3 = palette.textMuted
	end
end

-------------------------------------------------
-- 11. AÇÕES DOS BOTÕES
-------------------------------------------------
local function applySelected()
	local count = 0
	for name, state in pairs(selectedMap) do
		if state then
			local data = itemMap[name]
			if data then
				local banner = data.overhead:FindFirstChild("1OF1Banner")
				if banner then banner.Visible = true end
				forcedOneOfOne[name] = true
				count = count + 1
			end
		end
	end
	if count == 0 then
		status.Text = "Nenhum selecionado para aplicar"
		status.TextColor3 = Color3.fromRGB(255, 180, 80)
	else
		status.Text = "✓ Aplicado em " .. count .. " brainrot(s)"
		status.TextColor3 = palette.green
	end
	task.delay(2.5, function()
		local c = 0 for _ in pairs(selectedMap) do if selectedMap[_] then c = c + 1 end end
		status.Text = (c > 0 and c .. " selecionado(s)") or "Nenhum selecionado"
		status.TextColor3 = (c > 0 and palette.green) or palette.textMuted
	end)
end

local function removeSelected()
	local count = 0
	for name, state in pairs(selectedMap) do
		if state then
			local data = itemMap[name]
			if data then
				local banner = data.overhead:FindFirstChild("1OF1Banner")
				if banner then banner.Visible = false end
				forcedOneOfOne[name] = nil
				count = count + 1
			end
		end
	end
	if count == 0 then
		status.Text = "Nenhum selecionado para remover"
		status.TextColor3 = Color3.fromRGB(255, 180, 80)
	else
		status.Text = "✗ Removido de " .. count .. " brainrot(s)"
		status.TextColor3 = palette.textMuted
	end
	task.delay(2.5, function()
		local c = 0 for _ in pairs(selectedMap) do if selectedMap[_] then c = c + 1 end end
		status.Text = (c > 0 and c .. " selecionado(s)") or "Nenhum selecionado"
		status.TextColor3 = (c > 0 and palette.green) or palette.textMuted
	end)
end

local function clearSelection()
	for name, data in pairs(itemMap) do
		if selectedMap[name] then
			selectedMap[name] = false
			local check = data.row:FindFirstChild("CheckLabel")
			if check then check.Visible = false end
			tween(data.row, { BackgroundTransparency = 0.5 }, 0.1)
		end
	end
	status.Text = "Seleção limpa"
	status.TextColor3 = palette.textMuted
end

applyBtn.MouseButton1Click:Connect(applySelected)
removeBtn.MouseButton1Click:Connect(removeSelected)
clearBtn.MouseButton1Click:Connect(clearSelection)

-------------------------------------------------
-- 12. SCAN (COM PERSISTÊNCIA)
-------------------------------------------------
local function findPodiums()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end
	for _, plot in pairs(plots:GetChildren()) do
		local sign = plot:FindFirstChild("PlotSign")
		if sign then
			local sg = sign:FindFirstChild("SurfaceGui")
			if sg then
				local frame = sg:FindFirstChild("Frame")
				if frame then
					local label = frame:FindFirstChild("TextLabel")
					if label and label.Text == localPlayer.DisplayName .. "'s Base" then
						return plot:FindFirstChild("AnimalPodiums")
					end
				end
			end
		end
	end
	return nil
end

local function scan()
	clearItems()
	status.Text = "Scanning…"
	status.TextColor3 = palette.textMuted
	status.Visible = true

	local podiums = findPodiums()
	if not podiums then
		status.Text = "Aguardando seu plot…"
		return
	end

	local debrisItems = {}
	for _, item in pairs(workspace.Debris:GetChildren()) do
		local overhead = item:FindFirstChild("AnimalOverhead")
		if overhead then
			local dName = overhead:FindFirstChild("DisplayName")
			local gen = overhead:FindFirstChild("Generation")
			local motor = item:FindFirstChildWhichIsA("Motor6D")
			if dName and gen and motor and motor.Part1 then
				table.insert(debrisItems, {
					pos = motor.Part1.Position,
					name = dName.Text,
					gen = gen.Text,
					overhead = overhead,
				})
			end
		end
	end

	local matched = {}
	local used = {}
	local sorted = podiums:GetChildren()
	table.sort(sorted, function(a, b) return tonumber(a.Name) < tonumber(b.Name) end)

	for _, podium in pairs(sorted) do
		local base = podium:FindFirstChild("Base")
		local spawn = base and base:FindFirstChild("Spawn")
		if spawn then
			local attachPos = spawn.Position
			local nearest, nearestDist, nearestIdx = nil, math.huge, nil
			for i, item in pairs(debrisItems) do
				if not used[i] then
					local d = (item.pos - attachPos).Magnitude
					if d < nearestDist then
						nearestDist = d
						nearest = item
						nearestIdx = i
					end
				end
			end
			if nearest and nearestDist < 15 then
				used[nearestIdx] = true
				table.insert(matched, { name = nearest.name, gen = nearest.gen, overhead = nearest.overhead })
			end
		end
	end

	local filtered = {}
	for _, m in pairs(matched) do
		if isValidBrainrot(m.name) then
			table.insert(filtered, m)
		end
	end

	if #filtered == 0 then
		status.Text = "Nenhum brainrot válido na sua base."
		status.TextColor3 = palette.textMuted
		return
	end

	status.Visible = false
	for i, m in pairs(filtered) do
		createItem(m.name, m.gen, m.overhead, i)
	end

	restoreSelections()

	local contentH = layout.AbsoluteContentSize.Y + 20 + 70
	local targetH = math.min(contentH, 340) + 34
	tween(main, { Size = UDim2.new(0, 340, 0, math.max(targetH, 180)) }, 0.2)
end

-------------------------------------------------
-- 13. AUTO-SCAN
-------------------------------------------------
local scanPending = false
local function scheduleScan()
	if scanPending then return end
	scanPending = true
	task.delay(0.5, function()
		scanPending = false
		scan()
	end)
end

task.spawn(function()
	while not findPodiums() do task.wait(1) end
	scan()
end)

local Debris = workspace:WaitForChild("Debris")
Debris.ChildAdded:Connect(function(child)
	task.defer(function()
		if child:FindFirstChild("AnimalOverhead") then scheduleScan() end
	end)
end)
Debris.ChildRemoved:Connect(function(child)
	if child:FindFirstChild("AnimalOverhead") then scheduleScan() end
end)