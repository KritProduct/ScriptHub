local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local Window = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/UI/Window.lua"))()
local Tabs = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/UI/Tabs.lua"))()
local ModuleButton = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/UI/ModuleButton.lua"))()
local Fly = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Fly.lua"))()
local Noclip = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Noclip.lua"))()
local Speed = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Speed.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/ESP.lua"))()
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Aimbot.lua"))()
local TriggerBot = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/TriggerBot.lua"))()

local window = Window.Create(player)
local tabs = Tabs.Create(window.LeftPanel)

tabs.CreateTab("Movement", 10)
tabs.CreateTab("Visuals", 60)
tabs.CreateTab("Combat", 110)

local moduleContainer = Instance.new("ScrollingFrame")
moduleContainer.Size = UDim2.new(1, -20, 1, -20)
moduleContainer.Position = UDim2.new(0, 10, 0, 10)
moduleContainer.BackgroundTransparency = 1
moduleContainer.BorderSizePixel = 0
moduleContainer.CanvasSize = UDim2.new(0, 0, 0, 600)
moduleContainer.ScrollBarThickness = 3
moduleContainer.Parent = window.RightPanel

local moduleList = Instance.new("UIListLayout")
moduleList.Padding = UDim.new(0, 8)
moduleList.Parent = moduleContainer

local allModules = {}

local function createSlider(parent, min, max, current, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 50, 0, 20)
    label.Position = UDim2.new(1, -50, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = tostring(math.floor(current))
    label.TextColor3 = Color3.fromRGB(80, 140, 255)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 11
    label.Parent = container
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -60, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 20)
    track.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    track.BorderSizePixel = 0
    track.Parent = container
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 0, 6)
    fill.Position = UDim2.new(0, 0, 0, 20)
    fill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    fill.BorderSizePixel = 0
    fill.Parent = container
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill
    
    local function updateVisual(value)
        local percent = (value - min) / (max - min)
        fill.Size = UDim2.new(0, percent * track.AbsoluteSize.X, 0, 6)
        label.Text = tostring(math.floor(value))
    end
    
    updateVisual(current)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local RunService = game:GetService("RunService")
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local mouseX = UserInputService:GetMouseLocation().X
                local startX = track.AbsolutePosition.X
                local endX = track.AbsolutePosition.X + track.AbsoluteSize.X
                local percent = math.clamp((mouseX - startX) / (endX - startX), 0, 1)
                local value = min + percent * (max - min)
                updateVisual(value)
                if callback then callback(value) end
            end)
            
            local endConnection
            endConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                    endConnection:Disconnect()
                end
            end)
        end
    end)
    
    return container
end

local function createToggle(parent, text, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 22)
    toggle.Position = UDim2.new(1, -40, 0.5, -11)
    toggle.Text = ""
    toggle.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 11)
    toggleCorner.Parent = toggle
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = UDim2.new(0, 3, 0.5, -8)
    dot.BackgroundColor3 = Color3.fromRGB(160, 160, 160)
    dot.BorderSizePixel = 0
    dot.Parent = toggle
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0, 8)
    dotCorner.Parent = dot
    
    local enabled = default or false
    
    local function updateToggle()
        if enabled then
            toggle.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
            dot.Position = UDim2.new(1, -19, 0.5, -8)
            dot.BackgroundColor3 = Color3.new(1, 1, 1)
        else
            toggle.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            dot.Position = UDim2.new(0, 3, 0.5, -8)
            dot.BackgroundColor3 = Color3.fromRGB(160, 160, 160)
        end
    end
    
    updateToggle()
    
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateToggle()
        if callback then callback(enabled) end
    end)
    
    return container
end

local function createModule(name, tab, toggleCallback, settingsBuilder)
    local moduleData = ModuleButton.Create(moduleContainer, name, tab, toggleCallback, settingsBuilder)
    table.insert(allModules, moduleData)
    return moduleData
end

createModule("FLY", "Movement", function(enabled)
    if enabled then Fly.Start(player) else Fly.Stop() end
end, function(content)
    createSlider(content, 10, 250, Fly.Speed, function(v) Fly.Speed = v end)
end)

createModule("NOCLIP", "Movement", function(enabled)
    if enabled then Noclip.Start(player) else Noclip.Stop(player) end
end)

createModule("SPEED", "Movement", function(enabled)
    if enabled then Speed.Start(player) else Speed.Stop() end
end, function(content)
    createSlider(content, 5, 500, Speed.Strength, function(v) Speed.Strength = v end)
end)

createModule("ESP", "Visuals", function(enabled)
    if enabled then ESP.Start(player) else ESP.Stop() end
end)

createModule("AIMBOT", "Combat", function(enabled)
    if enabled then Aimbot.Start(player) else Aimbot.Stop() end
end, function(content)
    createSlider(content, 10, 180, Aimbot.FOV, function(v) Aimbot.FOV = v end)
    createSlider(content, 1, 20, Aimbot.Speed, function(v) Aimbot.Speed = v end)
    createToggle(content, "Wall Check", Aimbot.WallCheck, function(v) Aimbot.WallCheck = v end)
    createToggle(content, "Friend Check", Aimbot.FriendCheck, function(v) Aimbot.FriendCheck = v end)
end)

createModule("TRIGGER BOT", "Combat", function(enabled)
    if enabled then TriggerBot.Start(player) else TriggerBot.Stop() end
end)

tabs.SetOnChanged(function(tabName)
    for _, moduleData in pairs(allModules) do
        moduleData.SetVisible(moduleData.Tab == tabName)
    end
end)

tabs.SetActiveTab("Movement")

window.CloseBtn.MouseButton1Click:Connect(function()
    window.Toggle()
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K then
        window.Toggle()
    end
end)

local function makeDraggable(frame, handle)
    local dragging = false
    local startPos = nil
    local frameStart = nil
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = input.Position
            frameStart = frame.Position
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - startPos
            frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(window.Main, window.TitleBar)

print("Script Hub loaded!")
print("K - toggle menu")
